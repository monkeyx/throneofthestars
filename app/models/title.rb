class Title < ActiveRecord::Base
  include Comparable

  attr_accessible :character, :obtained_date, :category, :sub_category, :noble_house, :estate, :starship, :army, :unit, :region, :world

  NONE = ''

  NOBLE = "Noble"
  CHURCH = "Ecclesiastical"
  DOMAIN = "Domain"
  CHIVALROUS = "Chivalrous"

  TITLE_CATEGORIES = [NOBLE, CHURCH, DOMAIN, CHIVALROUS]

  BARON = "Baron"
  LORD = "Lord"
  EARL = "Earl"
  VISCOUNT = "Viscount"
  DUKE = "Duke"
  GRAND_DUKE = "Grand Duke"
  EMPEROR = "Emperor"
  BARONESS = "Baroness"
  LADY = "Lady"
  COUNTESS = "Countess"
  DUCHESS = "Duchess"
  EMPRESS = "Empress"

  MARRIAGE_TITLES = [BARONESS,LADY,COUNTESS,DUCHESS,EMPRESS]
  NOBLE_TITLES = [BARON,LORD,EARL,VISCOUNT,DUKE,GRAND_DUKE,EMPEROR] + MARRIAGE_TITLES

  WIFE_TITLE = {BARON => BARONESS, LORD => LADY, EARL => COUNTESS, DUKE => DUCHESS, EMPEROR => EMPRESS}

  ACOLYTE = "Acolyte"
  DEACON = "Deacon"
  BISHOP = "Bishop"
  ARCHBISHOP = "Archbishop"
  PONTIFF = "Pontiff"

  CHURCH_TITLES = [ACOLYTE, DEACON, BISHOP, ARCHBISHOP, PONTIFF]

  CHANCELLOR = "Chancellor"
  STEWARD = "Steward"
  TRIBUNE = "Tribune"
  
  DOMAIN_TITLES = [CHANCELLOR,STEWARD,TRIBUNE]
  
  KNIGHT = "Knight"
  
  CHIVALROUS_TITLES = [KNIGHT]

  CAPTAIN = "Captain"
  LIEUTENANT = "Lieutenant"

  NAVAL_TITLES = [CAPTAIN,LIEUTENANT]

  LEGATE = "Legate"

  ARMY_TITLES = [LEGATE]

  EMISSARY = "Emissary"

  DIPLOMATIC_TITLES = [EMISSARY]

  WARD = "Ward"
  LADY_IN_WAITING = "Lady-in-Waiting"
  ENSIGN = "Ensign"
  SQUIRE = "Squire"

  APPRENTICE_TITLES = [SQUIRE,ENSIGN,WARD,LADY_IN_WAITING]

  MILITARY_TITLES = ARMY_TITLES + CHIVALROUS_TITLES

  CIVIL_TITLES = [CHANCELLOR,STEWARD,TRIBUNE]

  CREW_TITLES = [LIEUTENANT,ENSIGN]

  MILITARY_OR_NAVAL_TITLES = ARMY_TITLES + NAVAL_TITLES

  LOCATION_FIXED_TITLES = [DEACON,STEWARD,TRIBUNE,CAPTAIN,LIEUTENANT,LEGATE,EMISSARY]
  
  TITLE_TYPES = NOBLE_TITLES + CHURCH_TITLES + DOMAIN_TITLES + CHIVALROUS_TITLES + DIPLOMATIC_TITLES + APPRENTICE_TITLES + NAVAL_TITLES + ARMY_TITLES

  SALUTATIONS = {NONE => 'Master',
  BARON => "My Lord",
  LORD => "My Lord",
  EARL => "My Lord",
  VISCOUNT => "My Lord",
  DUKE => "My Lord Duke",
  GRAND_DUKE => "My Grand Duke",
  EMPEROR => "Your Majesty",
  BARONESS => "Madam",
  LADY => "Madam",
  COUNTESS => "Madam",
  DUCHESS => "Madam",
  EMPRESS => "Your Majesty",
  ACOLYTE => "Brother",
  DEACON => "Deacon",
  BISHOP => "My Lord",
  ARCHBISHOP => "Your Grace",
  PONTIFF => "Pontiff",
  CHANCELLOR => "My Lord Chancellor",
  STEWARD => "Mister",
  TRIBUNE => "Mister",
  LEGATE => "Legate",
  CAPTAIN => "Captain",
  LIEUTENANT => "Lieutenant",
  WARD => "Master",
  LADY_IN_WAITING => "Lady",
  ENSIGN => "Ensign",
  KNIGHT => "Sir",
  SQUIRE => "Esquire",
  EMISSARY => "Ambassador"
  }

  RANKS = {NONE => 0.0,
  BARON => 5.2,
  LORD => 5.0,
  EARL => 6.0,
  VISCOUNT => 7.0,
  DUKE => 8.0,
  GRAND_DUKE => 9.0,
  EMPEROR => 10.0,
  BARONESS => 4.7,
  LADY => 4.5,
  COUNTESS => 5.5,
  DUCHESS => 7.5,
  EMPRESS => 9.5,
  ACOLYTE => 1.2,
  DEACON => 3.0,
  BISHOP => 6.0,
  ARCHBISHOP => 8.0,
  PONTIFF => 10.0,
  CHANCELLOR => 4.0,
  STEWARD => 3.0,
  TRIBUNE => 2.0,
  LEGATE => 4.0,
  CAPTAIN => 4.0,
  LIEUTENANT => 2.0,
  WARD => 1.0,
  LADY_IN_WAITING => 1.0,
  ENSIGN => 1.1,
  KNIGHT => 3.0,
  SQUIRE => 1.3,
  EMISSARY => 2.0}
  
  belongs_to :character
  game_date :obtained_date
  validates_inclusion_of :category, :in => TITLE_CATEGORIES
  validates_inclusion_of :sub_category, :in => TITLE_TYPES
  belongs_to :noble_house
  belongs_to :estate
  belongs_to :starship
  belongs_to :army
  belongs_to :unit
  belongs_to :region
  belongs_to :world

  scope :belonging_to, lambda {|character|
    {:conditions => {:character_id => character.id}}
  }

  scope :of_house, lambda {|noble_house|
    {:conditions => ["character_id IN (?)",Character.of_house(noble_house)]}
  }

  scope :category, lambda {|category|
    {:conditions => {:sub_category => category}}
  }

  scope :categories, lambda {|categories|
    {:conditions => ["sub_category IN (?)", categories]}
  }

  scope :title, lambda {|sub_category|
    {:conditions => {:sub_category => sub_category}}
  }

  scope :noble_house, lambda {|noble_house|
    {:conditions => {:noble_house_id => noble_house.id}}
  }

  scope :estate, lambda {|estate|
    {:conditions => {:estate_id => estate.id}}
  }

  scope :regional_estates, lambda {|region|
    {:conditions => ['estate_id IN (?)',region.estates]}
  }

  scope :army, lambda {|army|
    {:conditions => {:army_id => army.id}}
  }

  scope :starship, lambda {|starship|
    {:conditions => {:starship_id => starship.id}}
  }

  scope :unit, lambda {|unit|
    {:conditions => {:unit_id => unit.id}}
  }

  scope :region, lambda {|region|
    {:conditions => {:region_id => region.id}}
  }

  scope :world_regions, lambda {|world|
    {:conditions => ['region_id IN (?)',world.regions]}
  }

  scope :world, lambda {|world|
    {:conditions => {:world_id => world.id}}
  }
  
  def self.remove_titles!(character,titles)
    revoked = []
    titles.each do |title_name|
      belonging_to(character).title(title_name).each do |title|
        revoked << title
        title.revoke!
      end
    end
    revoked
  end

  def self.remove_domain_titles!(character)
    remove_titles!(character, DOMAIN_TITLES)
  end

  def self.remove_noble_titles!(character)
    remove_titles!(character, NOBLE_TITLES)
  end

  def self.remove_church_titles!(character)
    remove_titles!(character, CHURCH_TITLES)
  end

  def self.remove_apprenticeship_titles!(character)
    remove_titles!(character, APPRENTICE_TITLES)
  end

  def self.remove_military_or_naval_titles!(character)
    remove_titles!(character,MILITARY_OR_NAVAL_TITLES)
  end

  def self.can_claim_earl?(character,region)
    return false unless character.baron?
    return false if region.earl
    total = 0
    vassals = 0
    region.estates.each do |estate|
      if estate.lord
        total += 1
        vassals += 1 if estate.lord.vassal_or_same_house_of?(character)
      end
    end
    (total * 0.66).to_i <= vassals
  end

  def self.can_claim_duke?(character,world)
    return false unless character.baron?
    return false if world.duke
    total = 0
    vassals = 0
    world.regions.each do |region|
      total += 1
      if region.earl
        vassals += 1 if region.earl.vassal_or_same_house_of?(character)
      end
    end
    (total * 0.66).to_i <= vassals
  end

  def self.can_claim_emperor?(character)
    return false unless character.baron?
    return false if Character.emperor
    total = 0
    vassals = 0
    World.all.each do |world|
      total += 1
      if world.duke
        vassals += 1 if world.duke.vassal_or_same_house_of?(character)
      end
    end
    vassals == total
  end

  def self.elect_deacon!(estate)
    return false unless estate && estate.has_building?(BuildingType.category(BuildingType::CHAPEL).first) && !estate.deacon
    acolytes = Character.region(estate.region).title(ACOLYTE).select{|c| c.adult?}
    unless acolytes.empty?
      acolyte = acolytes.sort{|a,b| b.noble_house.piety <=> a.noble_house.piety}.first
      remove_church_titles!(acolyte)
      acolyte.move_to_estate!(estate)
      add_title!(acolyte,DEACON,estate)
    end
  end

  def self.elect_bishop!(region)
    return false unless region && !region.bishop
    deacons = Title.title(DEACON).regional_estates(region).select{|t| !t.character.has_title?(BISHOP)}.map{|t| t.character}
    unless deacons.empty?
      deacon = deacons.sort{|a,b| b.noble_house.piety <=> a.noble_house.piety}.first
      add_title!(deacon,BISHOP,region)
      Starship.build_starship!("#{deacon.noble_house.name} Courier", StarshipConfiguration.courier.first, deacon.noble_house.home_estate, true)
      deacon.add_church_news!('CHURCH_GIFT',"of a new Courier because #{deacon.name} was elected Bishop of #{region.name}")
    end
  end

  def self.elect_archbishop!(world)
    return false unless world && !world.archbishop
    bishops = Title.title(BISHOP).world_regions(world).select{|t| !t.character.has_title?(ARCHBISHOP)}.map{|t| t.character}
    unless bishops.empty?
      bishop = bishops.sort{|a,b| b.noble_house.piety <=> a.noble_house.piety}.first
      add_title!(bishop,ARCHBISHOP,world)
      Starship.build_starship!("#{bishop.noble_house.name} Transport", StarshipConfiguration.imperial_transport.first, bishop.noble_house.home_estate, true)
      bishop.add_church_news!('CHURCH_GIFT',"of a new Imperial Transport because #{bishop.name} was elected Archbishop of #{world.name}")
    end
  end

  def self.elect_pontiff!
    return false if title(ARCHBISHOP).size < World.count
    archbishop = Title.title(ARCHBISHOP).map{|t| t.character}.sort{|a,b| b.noble_house.piety <=> a.noble_house.piety}.first
    add_title!(archbishop,PONTIFF)
  end

  def self.transfer_lordship!(character, estate)
    return false unless character && estate && estate.of_same_house?(character)
    remove_church_titles!(character)
    estate(estate).title(LORD).first.transfer!(character)
    true
  end

  def self.appoint_legate!(character, army)
    return false unless character && character.male? && army && army.of_same_house?(character)
    remove_domain_titles!(character)
    remove_church_titles!(character)
    remove_military_or_naval_titles!(character)
    remove_military_or_naval_titles!(army.legate) if army.legate
    add_title!(character,LEGATE,army)
    character.join_army!(army)
  end

  def self.win_knighthood!(character,region)
    return false unless character
    remove_church_titles!(character)
    add_title!(character,KNIGHT,region)
  end

  def self.appoint_captain!(character, starship)
    return false unless character && starship && starship.of_same_house?(character) && (character.at_same_estate?(starship.current_estate) || starship.orbiting?(character.current_world))
    remove_domain_titles!(character)
    remove_military_or_naval_titles!(character)
    remove_military_or_naval_titles!(starship.captain) if starship.captain
    Crew.unassign_crew!(starship, character)
    add_title!(character,CAPTAIN,starship)
    character.board_starship!(starship) unless starship.onboard?(character)
  end

  def self.appoint_lieutenant!(character, starship)
    return false unless character && starship && starship.of_same_house?(character) && (character.at_same_estate?(starship.current_estate) || starship.orbiting?(character.current_world))
    remove_domain_titles!(character)
    remove_military_or_naval_titles!(character)
    remove_titles!(character,CREW_TITLES)
    add_title!(character,LIEUTENANT,starship)
    character.board_starship!(starship) unless starship.onboard?(character)
  end

  def self.appoint_steward!(character, estate)
    return false unless character && estate && character.current_region && character.current_region.id == estate.region.id && !character.lord?
    remove_domain_titles!(character)
    remove_domain_titles!(estate.steward) if estate && estate.steward
    remove_military_or_naval_titles!(character)
    add_title!(character,STEWARD,estate)
  end

  def self.appoint_tribune!(character, estate)
    return false unless character && estate && character.current_region && character.current_region.id == estate.region.id && !character.lord?
    remove_domain_titles!(character)
    remove_domain_titles!(estate.tribune) if estate.tribune
    remove_military_or_naval_titles!(character)
    add_title!(character,TRIBUNE,estate)
  end

  def self.appoint_chancellor!(character, noble_house)
    return false unless character && !character.baron?
    remove_domain_titles!(character)
    remove_domain_titles!(noble_house.chancellor) if noble_house.chancellor
    remove_military_or_naval_titles!(character)
    add_title!(character,CHANCELLOR,noble_house)
  end

  def self.appoint_emissary!(character, estate)
    return false unless character && estate && character.location_type == 'Estate' && character.location_id == estate.id && estate.foreign_to?(character)
    remove_domain_titles!(character)
    remove_military_or_naval_titles!(character)
    add_title!(character,EMISSARY,estate)
  end

  def self.become_acolyte!(character, estate)
    return false unless character && character.can_join_clergy? && estate && character.current_estate && estate.can_join_clergy?
    remove_noble_titles!(character)
    remove_domain_titles!(character)
    remove_military_or_naval_titles!(character)
    add_title!(character,ACOLYTE)
    character.move_to_estate!(estate)
  end

  def self.appoint_squire!(character, unit)
    return false unless character && character.novice?
    add_title!(character,SQUIRE)
    character.join_unit!(unit) if unit
  end

  def self.appoint_ensign!(character, starship)
    return false unless character && character.novice?
    add_title!(character,ENSIGN)
    character.board_starship!(starship) if starship
  end

  def self.become_ward!(character, estate)
    return false unless character && character.novice? && character.male?
    add_title!(character,WARD)
    character.move_to_estate!(estate,true) if estate
  end

  def self.become_lady_in_waiting!(character, estate)
    return false unless character && character.novice? && character.female?
    add_title!(character,LADY_IN_WAITING)
    character.move_to_estate!(estate,true) if estate
  end

  def self.add_title!(character,title_name,position=nil)
    category = if NOBLE_TITLES.include?(title_name)
      NOBLE
    elsif DOMAIN_TITLES.include?(title_name) || MILITARY_TITLES.include?(title_name) || NAVAL_TITLES.include?(title_name) || APPRENTICE_TITLES.include?(title_name)
      DOMAIN
    elsif CHIVALROUS_TITLES.include?(title_name)
      CHIVALROUS
    else
      CHURCH
    end
    title = create!(:character => character, :category => category, :sub_category => title_name, :obtained_date => Game.current_date)#
    title.set_position(position,title_name) unless position.nil?
    title.give_wife_title!
    if title.noble? && !title.marriage?
      character.add_empire_news!("ADD_TITLE",title.full_title)
    elsif title.church? && title.sub_category != ACOLYTE
      character.add_church_news!("ADD_TITLE",title.full_title)
    else
      character.add_news!("ADD_TITLE",title.full_title)
    end
    title
  end

  def noble?
    self.category == NOBLE
  end

  def domain?
    self.category == DOMAIN
  end

  def military?
    MILITARY_TITLES.include?(self.sub_category)
  end

  def naval?
    NAVAL_TITLES.include?(self.sub_category)
  end

  def civil?
    CIVIL_TITLES.include?(self.sub_category)
  end

  def church?
    CHURCH_TITLES.include?(self.sub_category)
  end

  def emissary?
    self.sub_category == EMISSARY
  end

  def marriage?
    MARRIAGE_TITLES.include?(self.sub_category)
  end

  def lord?
    self.sub_category == LORD
  end

  def baron?
    self.sub_category == BARON
  end

  def legate?
    self.sub_category == LEGATE
  end

  def knight?
    self.sub_category == KNIGHT
  end

  def squire?
    self.sub_category == SQUIRE
  end

  def ward?
    self.sub_category == WARD
  end

  def lady_in_waiting?
    self.sub_category == LADY_IN_WAITING
  end

  def ensign?
    self.sub_category == ENSIGN
  end

  def can_issue_orders?(position)
    return case position.class
    when Estate
      position == self.estate
    when Starship
      position == self.starship
    when Army
      position == self.army
    else
      false
    end
  end

  def transferable?
    self.category == NOBLE
  end

  def transfer!(character,transferable_override=false)
    return unless transferable? || transferable_override
    self.obtained_date = Game.current_date
    old_character = self.character
    self.character = character
    save!
    old_character.check_cancel_training! unless old_character.dead?
    set_position(territory,self.sub_category,character) unless territory.nil?
    if baron?
      self.noble_house.cease!(character.noble_house) unless character.noble_house_id == self.noble_house_id
    end
    character.add_news!("ADD_TITLE",full_title)
    old_character.add_news!("LOSE_TITLE",full_title)
    give_wife_title!
  end

  def inheritable?
    self.category == NOBLE && !MARRIAGE_TITLES.include?(self.sub_category)
  end

  def revoke!
    self.character.add_news!("LOSE_TITLE",full_title)
    set_position(self.territory,self.sub_category, nil)
    destroy
    if church?
      Title.elect_deacon!(self.estate) if self.estate
      Title.elect_bishop!(self.region) if self.region
      Title.elect_archbishop!(self.world) if self.world
      Title.elect_pontiff! if self.sub_category == PONTIFF
    end
  end

  def wife_eligible_title
    @wife_eligible_title = WIFE_TITLE[self.sub_category]
  end

  def current_wife_title
    return nil unless wife_eligible_title
    list = if self.estate
      Title.estate(self.estate).title(wife_eligible_title)
    elsif self.region
      Title.region(self.region).title(wife_eligible_title)
    elsif self.world
      Title.world(self.world).title(wife_eligible_title)
    elsif wife_eligible_title == BARONESS
      Title.noble_house(self.noble_house).title(wife_eligible_title)
    elsif wife_eligible_title == EMPRESS
      Title.title(wife_eligible_title)
    end
    list.size > 0 ? list.first : nil
  end

  def give_wife_title!
    return false unless wife_eligible_title && self.character.spouse && self.character.male?
    title = current_wife_title
    unless title
      t = Title.create!(:character => self.character.spouse, :category => NOBLE, :sub_category => wife_eligible_title, :obtained_date => Game.current_date)
      t.set_position(territory)
      t.save!
      t.character.add_news!("ADD_TITLE_MARRIAGE",t.full_title)
    else
      title.transfer!(self.character.spouse)
    end
  end

  def territory
    self.estate || self.region || self.world || self.noble_house || self.starship || self.army || self.unit
  end

  def same_territory?(title)
    title && self.territory && title.territory && self.territory.class == title.territory.class && self.territory.id == title.territory.id
  end

  def yearly_honour
    return case self.sub_category
    when LADY
      5
    when COUNTESS
      10
    when DUCHESS
      20
    when EMPRESS
      50
    when LEGATE
      10
    when KNIGHT
      10
    when SQUIRE
      1
    when CAPTAIN
      10
    when LIEUTENANT
      5
    when ENSIGN
      1
    when STEWARD
      2
    when TRIBUNE
      1
    when CHANCELLOR
      5
    when EMISSARY
      1
    when WARD
      1
    when LADY_IN_WAITING
      1
    else
      0
    end
  end
  def yearly_glory
    return case self.sub_category
    when LORD
      10
    when EARL
      50
    when VISCOUNT
      75
    when DUKE
      100
    when GRAND_DUKE
      150
    when EMPEROR
      500
    else
      0
    end
  end
  def yearly_piety
    return case self.sub_category
    when DEACON
      25
    when BISHOP
      50
    when ARCHBISHOP
      100
    when PONTIFF
      500
    when EMISSARY
      1
    when ACOLYTE
      1
    else
      0
    end
  end

  def short_title
    self.sub_category
  end

  def full_title
    if territory
      prefix = case territory.class.name
      when 'NobleHouse'
        'House '
      when 'Starship'
        'SS '
      else
        ''
      end
      suffix = case territory.class.name
      when 'Army'
        ' Army'
      when 'Unit'
        " of #{territory.army.name} Army"
      when 'Estate'
        " Estate"
      else
        ''
      end
      if self.sub_category == EMISSARY
        preposition = "at"
      else
        preposition = "of"
      end
      "#{self.sub_category} #{preposition} #{prefix}#{territory.name}#{suffix}"
    else
      "#{self.sub_category}"
    end
  end

  def salutation
    SALUTATIONS[self.sub_category]
  end
  
  def rank
    RANKS[sub_category]
  end

  def <(t)
    self.rank < t.rank
  end

  def >(t)
    self.rank > t.rank
  end

  def <=>(t)
  	self.rank <=> t.rank
	end

  def set_position(position,title_name=self.sub_category, character=self.character)
    case position.class.name
    when "NobleHouse"
      self.noble_house = position unless self.destroyed?
      if title_name == BARON
        position.baron = character if title_name == BARON
      end
      position.chancellor = character if title_name == CHANCELLOR
    when "Estate"
      self.estate = position unless self.destroyed?
      position.lord = character if title_name == LORD
      position.steward = character if title_name == STEWARD
      position.tribune = character if title_name == TRIBUNE
      position.deacon = character if title_name == DEACON
    when "Army"
      self.army = position unless self.destroyed?
      position.legate = character if title_name == LEGATE
    when "Starship"
      self.starship = position unless self.destroyed?
      position.captain = character if title_name == CAPTAIN
    when "Unit"
      self.unit = position unless self.destroyed?
      position.knight = character if title_name == KNIGHT
    when "Region"
      self.region = position unless self.destroyed?
      position.earl = character if title_name == EARL
      position.bishop = character if title_name == BISHOP
    when "World"
      self.world = position unless self.destroyed?
      position.duke = character if title_name == DUKE
      position.archbishop = character if title_name == ARCHBISHOP
    end
    position.save! if position
    save! unless self.destroyed?
  end
end
