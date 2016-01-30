class Character < ActiveRecord::Base
  attr_accessible :guid, :name, :category, :noble_house, :noble_house_id, :father, :father_id, :mother, :mother_id, :betrothed, :betrothed_id, :spouse, :spouse_id, :gender, :birth_date, :dead, :death_date, :birth_place, :health, :action_points, :action_points_modifier, :life_expectancy, :intimidation, :influence, :honour_modifier, :glory_modifier, :piety_modifier, :location, :location_type, :location_id, :wealth, :loyalty, :pension

  MAJOR = "Major"
  MINOR = "Minor"

  MALE = "Male"
  FEMALE = "Female"

  GENDERS = [MALE,FEMALE]

  self.per_page = 15

  before_save :generate_guid

  validates_presence_of :name

  validates_inclusion_of :category, :in => [MAJOR,MINOR]

  scope :major, :conditions => {:category => MAJOR}
  scope :minor, :conditions => {:category => MINOR}

  belongs_to :noble_house

  scope :of_house, lambda {|house|
    {:include => [:noble_house], :conditions => {:noble_house_id => house.id}, :order => 'birth_date ASC'}
  }

  belongs_to :father, :class_name => 'Character'
  belongs_to :mother, :class_name => 'Character'
  scope :children, lambda {|character|
    {:conditions => ["father_id = ? OR mother_id = ?",character.id,character.id]}
  }
  scope :siblings, lambda {|character|
    {:conditions => ["father_id = ? AND id <> ?",character.father.id, character.id]}
  }

  belongs_to :betrothed, :class_name => 'Character'
  belongs_to :spouse, :class_name => 'Character'
  validates_inclusion_of :gender, :in => GENDERS
  scope :male, :conditions => {:gender => MALE}
  scope :female, :conditions => {:gender => FEMALE}
  scope :betrothed, :conditions => "betrothed_id IS NOT NULL AND betrothed_id <> 0"

  game_date :birth_date
  belongs_to :birth_place, :class_name => 'Estate'
  # dead
  game_date :death_date
  validates_numericality_of :health, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_numericality_of :action_points, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10
  validates_numericality_of :action_points_modifier
  game_date :life_expectancy

  scope :life_expired, :conditions => {:life_expectancy => Game.current_date, :dead => false}

  validates_numericality_of :intimidation
  validates_numericality_of :influence
  validates_numericality_of :honour_modifier
  validates_numericality_of :glory_modifier
  validates_numericality_of :piety_modifier

  validates_numericality_of :wealth

  scope :at, lambda {|location|
    {:conditions => {:location_type => location.class.to_s, :location_id => location.id}}
  }

  scope :region, lambda {|region|
    {:conditions => ["location_type = 'Estate' and location_id IN (?)",region.estates]}
  }

  scope :region, lambda {|world|
    {:conditions => ["location_type = 'Estate' and location_id IN (?)",world.estates]}
  }

  scope :noble, :conditions => ["id IN (SELECT character_id FROM titles where category = ?)",Title::NOBLE]
  scope :church, :conditions => ["id IN (SELECT character_id FROM titles where category = ?)",Title::CHURCH]
  scope :domain, :conditions => ["id IN (SELECT character_id FROM titles where category = ?)",Title::DOMAIN]
  scope :knight, :conditions => ["id IN (SELECT character_id FROM titles where category = ?)",Title::CHIVALROUS]

  scope :title, lambda {|title_sub_category|
    {:conditions => ["id IN (SELECT character_id FROM titles WHERE sub_category = ?)",title_sub_category]}
  } 

  scope :exclude, lambda {|character|
    {:conditions => ["id <> ?",character.id]}
  }

  scope :prisoner, :conditions => "id IN (SELECT character_id FROM prisoners)"

  scope :entrants, lambda {|tournament|
    {:conditions => ["id in (SELECT character_id FROM tournament_entrants WHERE tournament_id = ?)",tournament.id]}
  }

  scope :guests, lambda {|wedding|
    {:conditions => ["id in (SELECT character_id FROM wedding_invites WHERE wedding_id = ?)",wedding.id]}
  }

  validates_numericality_of :loyalty, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_numericality_of :pension

  has_many :traits, :dependent => :destroy
  has_many :skills, :order => 'rank DESC', :dependent => :destroy

  has_many :marriage_proposals, :dependent => :destroy
  has_many :wedding_invites, :dependent => :destroy

  has_one :crew, :dependent => :destroy
  has_one :apprenticeship, :foreign_key => 'novice_id', :class_name => 'Apprentice', :conditions => 'accepted = 1', :dependent => :destroy
  has_many :apprentices, :conditions => 'accepted = 1', :dependent => :destroy
  has_one :prisoner, :dependent => :destroy

  has_many :titles, :dependent => :destroy

  scope :living, :conditions => {:dead => false}
  scope :dead, :conditions => {:dead => true}

  has_many :orders, :dependent => :destroy

  has_many :tournament_entrants, :dependent => :destroy

  include Comparable
  include Names
  include Locatable
  include Wealthy
  include NewsLog
  include HousePosition
  include Characters::Development
  include Characters::Health
  include Characters::Movement
  include Characters::Birth
  include Characters::Family
  include Characters::Marriage
  include Characters::Combat
  include Characters::Emissary

  def self.player_barons(exclude=nil)
    list = NobleHouse.player_owned.map{|house| house.baron}
    list = list.select{|b| b.id != exclude.id} if exclude
    list.sort{|a,b| a.display_name <=> b.display_name}
  end
  
  def self.emperor
    list = Title.title(Title::EMPEROR)
    list.size > 0 ? list.first.character : nil
  end

  def self.dukes
    Title.title(Title::DUKE).map{|title| title.character}
  end

  def self.pontiff
    list = Title.title(Title::PONTIFF)
    list.size > 0 ? list.first.character : nil
  end

  def self.archbishops
    Title.title(Title::ARCHBISHOP).map{|title| title.character}
  end

  def self.count_living(house)
    count(:conditions => ["dead = ? AND noble_house_id = ?",false,house.id])
  end

  def self.unemployed_of_house(house)
    of_house(house).to_a.map{|c| c if c.unemployed? }
  end

  def self.filter_skilled_characters(characters, skills)
    return characters if skills.length < 1
    candidates = []
    skills.each do |skill|
      candidates = candidates + filter_characters_with_skill(characters,skill)
    end
    candidates.uniq!
    candidates.sort!{|a,b| b.sum_skill_ranks <=> a.sum_skill_ranks }
    candidates
  end

  def self.filter_characters_with_skill(characters,skill)
    characters.select{|character| character.skill_rank(skill) > 0}
  end

  def self.potential_candidates(position, title_name,filter_by_skill=true)
    if filter_by_skill
      skills = case position.class.name
      when 'Estate'
        case title_name
        when Title::STEWARD
          Skill::USEFUL_STEWARD_SKILLS
        when Title::TRIBUNE
          Skill::USEFUL_TRIBUNE_SKILLS
        else
          []
        end
      when 'Starship'
        Skill::USEFUL_CREW_SKILLS
      when 'Army'
        Skill::USEFUL_ARMY_SKILLS
      when 'NobleHouse'
        Skill::USEFUL_CHANCELLOR_SKILLS
      else
        []
      end
    end
    characters = case title_name
    when Title::CHANCELLOR
      of_house(position).select {|character| character.unemployed? }
    when Title::STEWARD
      at(position).select {|character| character.unemployed? }
    when Title::TRIBUNE
      at(position).select {|character| character.unemployed? }
    when Title::LEGATE
      of_house(position.noble_house).at(position.location).male.select {|character| character.unemployed? }
    when Title::CAPTAIN
      of_house(position.noble_house).at(position.location).select {|character| character.unemployed? }
    when Title::LIEUTENANT
      of_house(position.noble_house).at(position.location).select {|character| character.unemployed? }
    else
      []
    end
    # count_before = characters.size
    characters = filter_by_skill ? filter_skilled_characters(characters, skills) : characters
    # count_after = characters.size
    # puts "Potential Candidates for #{position.name} #{title_name} before #{count_before} and after #{count_after}"
    characters
  end

  def self.seed!(name,noble_house,category=MINOR,gender=GENDERS.sample,birthdate=Game.current_date)
    c = Character.create!(:name => name, :noble_house => noble_house,
      :birth_date => birthdate, :gender => gender, :category => category)
    c.born!
    c.calculate_life_expectancy!
    c
  end

  def self.give_birth!(father,mother,birthplace=nil,birth_date=Game.current_date,gender=psuedo_random_gender,name=Names.random_name(gender))
    c = Character.create!(:father => father, :name => name, :noble_house => father.noble_house, 
      :birth_place => birthplace, :birth_date => birth_date, :location => birthplace,
      :gender => gender, :category => MINOR)
    c.mother = mother unless mother.nil?
    c.born!
    c.calculate_life_expectancy!
    c
  end

  def self.psuedo_random_gender
    rand(100) < 49 ? MALE : FEMALE
  end

  def self.move_home!(location)
    at(location).each{|c| c.move_to_home_estate!}
  end

  def self.limbo
    Character.living.select{|c| c.location.nil? }    
  end

  def self.move_out_of_limbo!
    Character.living.each do |c|
      if c.location.nil?
        c.move_to_home_estate!
      end
    end
  end

  def message_count
    @message_count ||= Message.message_count(self)
  end

  def estates
    @estates ||= titles.select{|t| t.lord?}.map{|t| t.estate }
  end

  def valid_orders
    @valid_orders ||= OrderProcessing::BaseOrderProcessor.orders_for_character(self)
  end

  def can_be_given_orders?
    adult? && self.prisoner.nil?
  end

  def major?
    @major ||= self.category == Character::MAJOR
  end

  def male?
    @male ||= self.gender == MALE
  end

  def female?
    @female ||= self.gender == FEMALE
  end

  def with_army?
    @with_army ||= location_army? || location_unit?
  end

  def onboard_ship?
    @onboard_ship ||= location_starship?
  end

  def at_foreign_estate?
    @at_foreign_estate ||= location_estate? && location_foreign?
  end

  def away_from_home?
    @away_from_home ||= with_army? || onboard_ship? || at_foreign_estate?
  end

  def action_points_per_chronum
    return @action_points_per_chronum if @action_points_per_chronum
    return @action_points_per_chronum = 4 if adult?
    return @action_points_per_chronum = 2 if novice?
    @action_points_per_chronum = 0
  end

  def alive?
    !dead?
  end

  def injured?
    has_trait?(Trait::SPECIAL_INJURED)
  end

  def injured!
    add_trait!(Trait::SPECIAL_INJURED)
  end

  def wounded?
    has_trait?(Trait::SPECIAL_WOUNDED)
  end

  def wounded!
    add_trait!(Trait::SPECIAL_WOUNDED)
  end

  def ill?
    has_trait?(Trait::SPECIAL_ILLNESS)
  end

  def ill!
    add_trait!(Trait::SPECIAL_ILLNESS)
  end

  def stressed?
    has_trait?(Trait::SPECIAL_STRESSED)
  end

  def stressed!
    add_trait!(Trait::SPECIAL_STRESSED)
  end

  def expired?
    self.life_expectancy.past?(Game.current_date)
  end

  def bastard?
    has_trait?(Trait::SPECIAL_BASTARD)
  end

  def inbred?
    has_trait?(Trait::SPECIAL_INBRED)
  end

  def is_married?
    !self.spouse.nil? && !self.spouse.dead?
  end

  def unmarried?
    !is_married?
  end

  def is_betrothed?
    !self.betrothed.nil? && !self.betrothed.dead?
  end
  
  def unbetrothed?
    !is_betrothed?
  end

  def single?
    of_marriage_age? && unmarried? && unbetrothed?
  end

  def single_male?
    single? && male?
  end

  def single_female?
    single? && female?
  end

  def age
    Game.current_date.difference(self.birth_date) / 10
  end

  def of_marriage_age?
    age >= 14
  end

  def infant?
    age < 7
  end

  def child?
    age >= 7 && age < 14
  end

  def infant_or_child?
    infant? || child?
  end

  def can_become_apprentice?
    (self.apprenticeship.nil? && novice? && age < 17)
  end

  def novice?
    age >= 14 && age < 18
  end

  def adult?
    age >= 18
  end

  def adult_male?
    adult? && male?
  end

  def parent_crazy?
    father.has_trait?(Trait::SPECIAL_CRAZED) || (mother && mother.has_trait?(Trait::SPECIAL_CRAZED))
  end

  def parent_kinslayer?
    father.has_trait?(Trait::SPECIAL_KINSLAYER) || (mother && mother.has_trait?(Trait::SPECIAL_KINSLAYER))
  end

  def can_be_major?
    return @can_be_major if @can_be_major
    self.traits.each{|trait|@can_be_major = false if trait.cannot_be_major?}
    @can_be_major = true unless @can_be_major
    @can_be_major
  end

  def can_have_apprentices?
    (lord? || lady? || baron? || baroness? || knight? || captain?)
  end

  def proposals
    (male? ? MarriageProposal.from(self).map{|mp| mp.target } : MarriageProposal.to(self).map{|mp| mp.character })
  end

  def accusations
    Accusation.concerning(self)
  end

  def accusations_against
    Accusation.accused(self)
  end

  def wedding
    Wedding.of(self).first
  end

  def apprenticeship_offers
    Apprentice.apprentices(self).pending
  end

  def apprenticeships_sought
    Apprentice.apprenticeship(self).pending
  end

  def can_marry?
    return @can_marry if @can_marry
    self.traits.each{|trait|@can_marry = false if trait.cannot_marry?}
    return @can_marry if @can_marry
    return @can_marry = false unless of_marriage_age?
    return @can_marry = false if is_married?
    return @can_marry = false if is_betrothed?
    return @can_marry = false if clergy? && Law.is_active?(Law::EDICT_CHASTITY)
    @can_marry = true
  end

  def can_join_clergy?
    return @can_join_clergy if @can_join_clergy
    return @can_join_clergy = false if church?
    return @can_join_clergy = false if self.baron? || self.lord?
    return @can_join_clergy = false if self.noble_house.piety < 0
    self.traits.each{|trait|return @can_join_clergy = false if trait.cannot_join_clergy?}
    @can_join_clergy = true
  end

  def gm?
    self.noble_house.gm?
  end

  def noble?
    Title.belonging_to(self).category(Title::NOBLE).size > 0
  end

  def church?
    (has_title?(Title::DEACON) || has_title?(Title::ACOLYTE) || has_title?(Title::BISHOP))
  end

  alias_method :clergy?, :church?

  def appointed?
    Title.belonging_to(self).categories(Title::DOMAIN_TITLES).size > 0
  end

  def has_title?(title_name)
    Title.belonging_to(self).title(title_name).size > 0
  end

  def emperor?
    has_title?(Title::EMPEROR)
  end

  def pontiff?
    has_title?(Title::PONTIFF)
  end

  def pontiff_or_emperor?
    emperor? || pontiff?
  end

  def lord?
    has_title?(Title::LORD)
  end

  def lady?
    has_title?(Title::LADY)
  end

  def baron?
    has_title?(Title::BARON)
  end

  def baroness?
    has_title?(Title::BARONESS)
  end

  def steward?
    has_title?(Title::STEWARD)
  end

  def management?
    lord? || steward?
  end

  def human_resources?
    lord? || tribune?
  end

  def chancellor?
    has_title?(Title::CHANCELLOR)
  end

  def tribune?
    has_title?(Title::TRIBUNE)
  end

  def knight?
    has_title?(Title::KNIGHT)
  end

  def legate?
    has_title?(Title::LEGATE)
  end

  def captain?
    has_title?(Title::CAPTAIN)
  end

  def lieutenant?
    has_title?(Title::LIEUTENANT)
  end

  def emissary?
    has_title?(Title::EMISSARY)
  end

  def emissary_or_tribune?
    emissary? || tribune?
  end

  def deacon?
    has_title?(Title::DEACON)
  end

  def bishop?
    has_title?(Title::BISHOP)
  end

  def archbishop?
    has_title?(Title::ARCHBISHOP)
  end

  def lord_or_deacon?
    lord? || deacon?
  end

  def can_tithe?
    lord? || deacon? || bishop?
  end

  def squire?
    has_title?(Title::SQUIRE)
  end

  def ward?
    has_title?(Title::WARD)
  end

  def lady_in_waiting?
    has_title?(Title::LADY_IN_WAITING)
  end

  def ensign?
    has_title?(Title::ENSIGN)
  end

  def acolyte?
    has_title?(Title::ACOLYTE)
  end

  def military?
    legate? || knight?
  end

  def naval?
    captain? || lieutenant?
  end

  def employed?
    adult? && (lord? || church? || appointed? || military? || naval? || emissary?)
  end

  def unemployed?
    (adult? && location_estate? && !lord? && !deacon? && !appointed?)
  end

  def trader?
    adult? && self.location && (location_starship? || location_estate?) && self.location.noble_house_id == self.noble_house_id
  end

  def doctor?
    skill_rank(Skill::CHURCH_MEDICINE) > 0
  end

  def can_be_healed?
    injured? || ill? || wounded?
  end

  def bishop_of?(region)
    Title.belonging_to(self).title(Title::BISHOP).region(region).size > 0
  end

  def archbishop_of?(world)
    Title.belonging_to(self).title(Title::ARCHBISHOP).world(world).size > 0
  end

  def earl_of?(region)
    Title.belonging_to(self).title(Title::EARL).region(region).size > 0
  end

  def duke_of?(world)
    Title.belonging_to(self).title(Title::DUKE).world(world).size > 0
  end

  def can_inherit?
    return @can_inherit if @can_inherit
    self.traits.each{|trait|return @can_inherit = false if trait.cannot_inherit?}
    @can_inherit = true
  end

  def vassal_or_same_house_of?(other_character)
    return false unless other_character && other_character.noble_house
    return true if other_character.noble_house_id == self.noble_house_id
    self.noble_house.vassal?(other_character.noble_house)
  end

  def has_trait?(trait_category)
    Trait.of(self).category(trait_category).size > 0
  end
  
  def highest_rank_of_skill
    return @highest_rank_of_skill if @highest_rank_of_skill
    @highest_rank_of_skill = 0
    self.skills.each do |skill|
      @highest_rank_of_skill = skill.rank if skill.rank > @highest_rank_of_skill
    end
    @highest_rank_of_skill
  end

  def expert?
    highest_rank_of_skill > Skill::APPRENTICE
  end

  def skill_rank(skill_category)
    Skill.skill_rank(self,skill_category)
  end

  def skill_rank_name(skill_category)
    Skill.skill_rank_name(self,skill_category)
  end

  def sum_skill_ranks
    Skill.of(self).to_a.sum{|s| s.rank}
  end

  def can_train_skill?(category)
    if Skill::CIVIL_SKILLS.include?(category)
      return true if lord? || steward? || chancellor? || tribune?
      # TODO science academy check
    elsif Skill::MILITARY_SKILLS.include?(category)
      return true if legate? || knight?
      # TODO grand academy check
    elsif Skill::NAVAL_SKILLS.include?(category)
      return true if lieutenant? || captain?
      # TODO engineering academy check
    elsif Skill::CHURCH_SKILLS.include?(category)
      return true if emissary? || deacon? || bishop?
    else
      return false
    end
  end

  def name_and_family
    "#{self.name} #{self.noble_house.name}"
  end

  def display_name_and_house
    "#{display_name} of House #{self.noble_house.name}"
  end

  def short_display_name
    display_name(true)
  end

  def display_name(short=false)
    t = highest_rank_title
    unless t
      if self.noble_house
        if short
          return name
        else
          return name_and_family
        end
      elsif self.father
        if short
          return name
        elsif male?
          return "#{self.name} son of #{self.father.name}"
        else
          return "#{self.name} daughter of #{self.father.name}"
        end
      else
        return name
      end
    end
    if t.noble?
      if t.territory
        return "#{t.short_title} #{t.territory.name}"
      else
        return "#{t.short_title} #{self.name}"
      end
    end
    if t.knight?
      return "Sir #{self.name} of #{t.region.name}"
    end
    if t.legate?
      return "Legate #{self.name_and_family}"
    end
    if t.church?
      if short
        return "#{t.short_title} #{self.name}"
      elsif t.territory
        return "#{t.short_title} #{self.name} of #{t.territory.name}"
      else
        return "#{t.short_title} #{self.name}"
      end
    end
    if t.domain?
      return "#{t.short_title} #{self.name_and_family}"
    end
    if t.squire?
      return "#{self.name_and_family} Esquire"
    end
    if t.lady_in_waiting?
      return "Lady #{self.name}"
    end
    if t.ward?
      return "Master #{self.name}"
    end
    if t.ensign?
      return "Ensign #{self.noble_house.name}"
    end
    if t.emissary?
      return "Emissary #{self.name_and_family}"
    end
    if t
      return "#{t.short_title} #{self.name_and_family}"
    end
    self.name
  end

  def salutation
    return @salutation if @salutation
    t = highest_rank_title
    @salutation = t.nil? ? Title::SALUTATIONS[Title::NONE] : t.salutation
  end

  def short_title
    return @short_title if @short_title
    t = highest_rank_title
    @short_title = t.nil? ? Title::NONE : t.short_title
  end

  def titles_sorted_by_rank
    self.titles.to_a.sort! { |a,b| b <=> a }
  end

  def full_titles
    titles_sorted_by_rank.map{|title| title.full_title}.join(", ")
  end

  def name_and_full_titles
    return @name_and_full_titles if @name_and_full_titles
    ft = full_titles
    ft = ", #{ft}" unless ft.blank?
    @name_and_full_titles = "#{self.name}#{ft}"
  end

  def highest_rank_title
    return @highest_rank_title if @highest_rank_title
    list = titles_sorted_by_rank
    @highest_rank_title = list.size > 0 ? list.first : nil
  end

  def rank
    return @rank if @rank
    t = highest_rank_title
    @rank = t.nil? ? Title::RANKS[Title::NONE] : t.rank
  end

  def <(c)
    self.rank < c.rank
  end

  def >(c)
    self.rank > c.rank
  end

  def <=>(c)
  	self.rank <=> c.rank
	end

  def to_s
    short_display_name
  end

  def promote!
    update_attributes!(:category => MAJOR)
    add_news!("PROMOTION",self.noble_house)
  end

  def increase_health!(amount)
    amount = (100 - (self.health)) if amount + self.health > 100
    update_attributes!(:health => self.health + amount)
  end

  def decrease_health!(amount)
    amount = self.health if self.health - amount < 0
    update_attributes!(:health => self.health - amount)
    die!("poor health") if self.health < 1
  end

  def add_action_points!(amount = action_points_per_chronum)
    return unless amount > 0
    amount = (amount * (1.0 + self.action_points_modifier)).round(0).to_i
    amount = 1 if amount < 1
    total = self.action_points + amount
    total = 10 if total > 10
    total = 0 if total < 0
    update_attributes!(:action_points => total)
  end

  def use_action_points!(amount)
    return false unless amount && amount > 0
    amount = self.action_points if amount > self.action_points
    update_attributes!(:action_points => self.action_points - amount)
  end

  def liege
    if baron?
      if self.noble_house.liege
        self.noble_house.liege.baron
      else
        nil
      end
    else
      self.noble_house.baron
    end
  end

  def increase_loyalty!(amount)
    amount = (100 - (self.loyalty)) if amount + self.loyalty > 100
    update_attributes!(:loyalty => self.loyalty + amount)
  end

  def decrease_loyalty!(amount)
    amount = self.loyalty if self.loyalty - amount < 0
    update_attributes!(:loyalty => self.loyalty - amount)
    leave! if loyalty < 1
  end

  def check_loyalty!
    leave! if loyalty <= 20 && "#{loyalty} in 1d20".success?
  end

  def add_honour!(amount)
    amount = amount * (1 + self.honour_modifier)
    self.noble_house.add_honour!(amount)
    amount
  end

  def lose_honour!(amount)
    amount = amount * (1 - self.honour_modifier)
    self.noble_house.lose_honour!(amount)
    amount
  end

  def add_glory!(amount)
    amount = amount * (1 + self.glory_modifier)
    self.noble_house.add_glory!(amount)
    amount
  end

  def lose_glory!(amount)
    amount = amount * (1 - self.glory_modifier)
    self.noble_house.add_glory!(amount)
    amount
  end

  def add_piety!(amount)
    amount = amount * (1 + self.piety_modifier)
    self.noble_house.add_piety!(amount)
    amount
  end

  def lose_piety!(amount)
    amount = amount * (1 - self.piety_modifier)
    self.noble_house.add_piety!(amount)
    amount
  end

  def inherit!(from)
    transaction do
      self.add_wealth!(from.wealth + from.pension)
      from.subtract_wealth!(from.wealth)
      if can_inherit?
        from.titles.each{|title| title.transfer!(self) if title.inheritable? }
      end
      Title.remove_church_titles!(self) if noble?
      Title.remove_domain_titles!(self) if baron?
      add_news!("INHERIT",from)
    end
  end

  def die!(cause=nil)
    transaction do 
      self.dead = true
      empire_news = self.noble?
      church_news = self.church? && !self.acolyte?
      if infant?
        desc = "before #{(male? ? 'his' : 'her')} time"
      else
        desc = "at the age of #{age}"
      end
      desc = desc + " due to #{cause}" unless cause.blank?
      desc = desc + " onboard SS #{self.location.name}" if location_starship?
      desc = desc + " at Estate #{self.location.name}" if location_estate?
      desc = desc + " whilst leading the #{self.location.name} Army" if location_army?
      desc = desc + " whilst travelling with the #{self.location.army.name} Army" if location_unit?
      if empire_news
        add_empire_news!("DIED",desc)
      elsif church_news
        add_church_news!("DIED",desc)
      else
        add_news!("DIED",desc)
      end
      self.death_date = Game.current_date
      if self.betrothed
        self.betrothed.update_attributes!(:betrothed_id => nil)
        self.betrothed = nil
      end
      wedding = Wedding.of(self).first
      wedding.cancel!("#{self.name} died") if wedding
      if self.prisoner
        self.prisoner.ransoms.destroy_all unless self.prisoner.ransoms.empty?
        self.prisoner.destroy 
      end
      self.apprentices.each do |apprentice|
        apprentice.end!
      end
      Accusation.concerning(self).each do |accusation|
        accusation.destroy
      end
      if self.location_starship? && self.location.captain_id == self.id
        self.location.assign_captain!(self.location.lieutenants.to_a.sample.character) if self.location.lieutenants.size > 0
      end
      self.apprenticeship.end! if self.apprenticeship
      self.location = nil
      heir = rightful_heir
      heir.inherit!(self) unless heir.nil?
      self.reload
      self.titles.each{|title| title.revoke!}
      save!
    end    
  end

  def leave!(to_house=nil)
    return if baron? # barons can never leave
    unless to_house
      if self.current_region 
        to_house = NobleHouse.in_region(self.current_region,self.noble_house).sample
      end
      if self.current_world
        to_house = NobleHouse.on_world(self.current_world,self.noble_house).sample
      end
      to_house = NobleHouse.active.sample
    end
    transaction do
      old_house = self.noble_house
      self.titles.each{|title| title.revoke!}
      self.noble_house = to_house
      self.loyalty = 100
      self.category = MINOR
      save!
      add_news!("LEFT_HOUSE",old_house)
      add_news!("JOIN_HOUSE",to_house) if to_house
    end
  end

  def exiled!
    heir = rightful_heir
    transaction do
      self.titles.each{|title| title.pass_to_heir!(heir)} unless heir.nil?
      add_trait!(Trait::SPECIAL_EXILED)
      lose_honour!((self.noble_house.honour / 10).to_i)
      add_empire_news!("EXILED",Character.emperor)
    end
  end

  def heretic!
    transaction do
      self.titles.each{|title| title.revoke! if title.church?}
      add_trait!(Trait::SPECIAL_HERETIC)
      lose_piety!((self.noble_house.piety / 10).to_i)
      add_church_news!("HERETIC", Character.pontiff)
    end
  end

  def add_title!(title_name,position=nil)
    Title.add_title!(self,title_name,position)
  end

  def add_trait!(trait_category)
    return if trait_category.blank? || has_trait?(trait_category)
    trait = self.traits.create!(:category => trait_category, :acquired_date => Game.current_date)
    self.honour_modifier += trait.honour_modifier
    self.glory_modifier += trait.glory_modifier
    self.piety_modifier += trait.piety_modifier
    self.action_points_modifier += trait.action_point_modifier
    self.influence += trait.influence_modifier
    self.intimidation += trait.intimidation_modifier
    self.decrease_health!(trait.lose_health)
    save!
    add_news!("ADD_TRAIT", trait_category)
    remove_trait!(trait.opposite_trait)
    calculate_life_expectancy!
  end

  def remove_trait!(trait_category)
    return if trait_category.blank? || !has_trait?(trait_category)
    trait = Trait.of(self).category(trait_category).first
    self.honour_modifier -= trait.honour_modifier
    self.glory_modifier -= trait.glory_modifier
    self.piety_modifier -= trait.piety_modifier
    self.action_points_modifier -= trait.action_point_modifier
    self.influence -= trait.influence_modifier
    self.intimidation -= trait.intimidation_modifier
    self.increase_health!(trait.lose_health)
    trait.destroy
    add_news!("LOSE_TRAIT", trait_category)
    save!
    calculate_life_expectancy!
  end

  def add_skill!(skill_category,rank=Skill::NEOPHYTE)
    s = Skill.add_skill!(self, skill_category, rank)
    add_news!("ADD_SKILL",s)
    s
  end

  def train!(category)
    add_news!("TRAIN_SKILL",category) if Skill.train_skill!(self,category)
  end

  def check_cancel_training!
    skill = Skill.currently_training_skill(self)
    if skill
      skill.stop_training! unless can_train_skill?(skill.category)
    end
    skill
  end

  def currently_training
    Skill.currently_training_skill(self)
  end

  def gain_experience!(skill_criteria_method)
    skill = currently_training
    if skill && skill.send(skill_criteria_method)
      tp_earned = "1d4".roll
      skill.update_attributes!(:training_points => skill.training_points + tp_earned)
      return tp_earned, skill
    end
    return 0, skill
  end

  def sword_fight_experience!
    gain_experience!(:swords?)
  end

  def lance_fight_experience!
    gain_experience!(:lances?)
  end

  def space_combat_experience!
    gain_experience!(:naval?)
  end

  def ground_combat_experience!
    gain_experience!(:military?)
  end

  def tithes_modifier
    sum_trait_modifiers(:piety_modifier) + sum_skill_modifiers(:tithe_modifier)
  end

  def pay_tithes!(amount)
    return false unless current_estate && current_estate.tithe_allowed?
    amount = self.noble_house.wealth if amount > self.noble_house.wealth
    modifier = current_estate.tithe_modifier + tithes_modifier
    piety = ((amount / 100.0) * modifier).round(0).to_i
    region = current_estate.region
    region.add_tithes!(amount)
    self.noble_house.add_piety!(piety)
    self.noble_house.subtract_wealth!(amount)
    add_news!('PAY_TITHES',"&pound; #{amount}")
  end

  def skill_training!
    training_skill = currently_training
    if training_skill
      if can_train_skill?(training_skill.category)
        training_skill.check_training!
      else
        training_skill.stop_training!
      end
    end
  end

  def tournaments
    @tournaments ||= self.tournament_entrants.select{|e| e.tournament.pending?}.map{|e| e.tournament}
  end

  def join_tournament!(tournament)
    raise "Female characters cannot join tournaments" if female?
    raise "Not in same location as tournament #{tournament.name}" unless self.location == tournament.estate
    tournament.join!(self)
    add_news!("JOIN_TOURNAMENT",tournamet.estate)
  end

  def calculate_life_expectancy!
    chronum = "60d20".roll
    multiplier = 1.0 + sum_trait_modifiers(:life_expectancy_modifier)
    chronum *= multiplier
    update_attributes!(:life_expectancy => self.birth_date + chronum.to_i)
  end

  def new_order
    Order.new_order(self)
  end

  def next_order
    Order.find(:first, :conditions => {:character_id => self.id})
  end

  def pending_orders
    Order.belongs_to(self).pending
  end

  def sum_trait_modifiers(method_sym)
    total = 0
    self.traits.each do |trait|
      total += trait.send(method_sym)
    end
    total
  end

  def sum_skill_modifiers(method_sym)
    total = 0
    self.skills.each do |skill|
      total += skill.send(method_sym)
    end
    total
  end

  def send_internal_message!(subject,content)
    Message.send_internal!(self,subject,content)
  end
end
