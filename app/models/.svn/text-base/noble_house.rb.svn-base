class NobleHouse < ActiveRecord::Base
  attr_accessible :player, :player_id, :baron, :chancellor, :name, :wealth, :honour, :glory, :piety, :formed_date, :ancient, :active,
  :patriarch, :patriarch_skill1, :patriarch_skill2, :patriarch_skill3, :matriarch, :matriarch_skill1, :matriarch_skill2, :matriarch_skill3, :first_child_name, :first_child_skill, :second_child_name, :second_child_skill, :third_child_name, :third_child_skill, :estate_name, :region
  
  self.per_page = 15

  MAXIMUM_MAJOR_CHARACTERS = 7
  STARTING_CASH = 25000
  
  before_save :floor_attributes

  belongs_to :player
  belongs_to :baron, :class_name => 'Character'
  belongs_to :chancellor, :class_name => 'Character'
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :wealth
  validates_numericality_of :honour
  validates_numericality_of :glory
  validates_numericality_of :piety
  game_date :formed_date
  # ancient
  scope :ancient, :conditions => {:ancient => true}
  # active
  scope :active, :conditions => {:ancient => false, :active => true}

  scope :active_or_ancient, :conditions => ['ancient = ? OR active = ?',true, true]

  scope :player_owned, :conditions => "player_id IS NOT NULL AND player_id <> 0"

  scope :exclude, lambda {|house|
    {:conditions => ['id <> ?', house.id]}
  }

  has_many :market_items, :dependent => :destroy
  has_many :diplomatic_relations, :dependent => :destroy
  has_many :prisoners, :dependent => :destroy
  has_many :news, :dependent => :destroy
  has_many :characters, :dependent => :destroy
  has_many :estates, :dependent => :destroy
  has_many :authorisations, :dependent => :destroy
  has_many :starships, :dependent => :destroy
  has_many :armies, :dependent => :destroy
  has_many :titles, :dependent => :destroy

  # sign up variables
  SIGNUP_VARIABLES = [:patriarch, :patriarch_skill1, :patriarch_skill2, :patriarch_skill3,
                :matriarch, :matriarch_skill1, :matriarch_skill2, :matriarch_skill3,
                :first_child_name, :first_child_skill,
                :second_child_name, :second_child_skill,
                :third_child_name, :third_child_skill,
                :estate_name, :region]
  attr_accessor :patriarch, :patriarch_skill1, :patriarch_skill2, :patriarch_skill3,
                :matriarch, :matriarch_skill1, :matriarch_skill2, :matriarch_skill3,
                :first_child_name, :first_child_skill,
                :second_child_name, :second_child_skill,
                :third_child_name, :third_child_skill,
                :estate_name, :region
  validate :validate_signup, :if => :signup?

  scope :ranked, :conditions => 'ancient = 1 OR active = 1', :order => 'glory DESC, honour DESC, piety DESC, name ASC'

  include Wealthy
  include NewsLog
  include Signup

  def self.gm
    Player.gm.noble_house
  end

  def self.on_world(world, exclude)
    return [] unless world
    if exclude
      world.estates.select{|e| e.noble_house.active? && e.noble_house.id != exclude.id}.map{|e| e.noble_house}.uniq.sort{|a,b| b.glory <=> a.glory }
    else
      world.estates.select{|e| e.noble_house.active? }.map{|e| e.noble_house}.uniq.sort{|a,b| b.glory <=> a.glory }
    end
  end

  def self.in_region(region, exclude)
    return [] unless region
    if exclude
      region.estates.select{|e| e.noble_house.active? && e.noble_house.id != exclude.id}.map{|e| e.noble_house}.uniq.sort{|a,b| b.glory <=> a.glory }
    else
      region.estates.select{|e| e.noble_house.active? }.map{|e| e.noble_house}.uniq.sort{|a,b| b.glory <=> a.glory }
    end
  end

  def self.total_active_or_ancient
    NobleHouse.count(:conditions => 'ancient = 1 OR active = 1')
  end

  def gm?
    Player.gm.noble_house.id == self.id
  end

  def rank
    NobleHouse.ranked.index(self) + 1
  end

  def page_number
    (rank.to_f / 15.0).ceil
  end

  def setup_region
    @region = Region.signup[0..9].sample.id
  end

  def signup_variables_hash
    hash = {:house_id => self.id}
    SIGNUP_VARIABLES.each do |attr|
      hash[attr] = send(attr)
    end
    hash
  end

  def name_with_ancient
    ancient? ? "#{name} [Ancient]" : name
  end

  def home_estate
    return @home_estate if @home_estate
    return nil if self.estates.size < 1
    return @home_estate = self.estates.first if self.estates.size == 1
    return @home_estate = self.baron.location if self.baron && self.baron.location && self.baron.location.is_a?(Estate)
    @home_estate = self.estates.first
  end

  def major_characters
    @major_characters ||= Character.of_house(self).major
  end

  def minor_characters
    @minor_characters ||= Character.of_house(self).minor
  end

  def single_males
    @single_males ||= self.characters.select{|c| c.male? && c.alive? && c.single?}
  end

  def single_females
    @single_females ||= self.characters.select{|c| c.female? && c.alive? && c.single?}
  end

  def major_characters_status
    @major_characters_status ||= "#{major_characters.size} of #{MAXIMUM_MAJOR_CHARACTERS}"
  end

  def maxed_majors?
    @maxed_majors ||= major_characters.size >= MAXIMUM_MAJOR_CHARACTERS
  end

  def automated_taxes?
    @automated_taxes ||= self.chancellor.exists?
  end

  def liege
    return @liege if @liege
    list = DiplomaticRelation.of(self).category(DiplomaticRelation::LIEGE)
    @liege = list.size > 0 ? list.first.target : nil
  end

  def vassals
    @vassals ||= DiplomaticRelation.of(self).category(DiplomaticRelation::VASSAL).map{|rel|rel.target}
  end

  def allies
    @allies ||= DiplomaticRelation.of(self).category(DiplomaticRelation::ALLY).map{|rel|rel.target}
  end

  def is_at_war?
    DiplomaticRelation.of(self).category(DiplomaticRelation::WAR).size > 0
  end

  def has_cassus_belli?
    @has_cassus_belli ||= DiplomaticRelation.of(self).category(DiplomaticRelation::CASSUS_BELLI).size > 0
  end

  def has_truce_offers?
    @has_truce_offers ||= DiplomaticRelation.with(self).category(DiplomaticRelation::TRUCE).pending.size > 0
  end

  def has_peace_offers?
    @has_peace_offers ||= DiplomaticRelation.with(self).category(DiplomaticRelation::PEACE).pending.size > 0
  end

  def has_alliance_offers?
    @has_alliance_offers ||= DiplomaticRelation.with(self).category(DiplomaticRelation::ALLY).pending.size > 0
  end

  def has_oath_offers?
    @has_oath_offers ||= DiplomaticRelation.with(self).category(DiplomaticRelation::LIEGE).pending.size > 0
  end

  def has_oath?
    liege || vassals.size > 0
  end

  def has_allies?
    allies.size > 0
  end

  def cassus_belli(other_house)
    DiplomaticRelation.of(self).with(other_house).category(DiplomaticRelation::CASSUS_BELLI).first
  end

  def current_war(other_house)
    DiplomaticRelation.of(self).with(other_house).category(DiplomaticRelation::WAR).first
  end

  def current_truce(other_house)
    DiplomaticRelation.with(self).of(other_house).category(DiplomaticRelation::TRUCE).pending.last
  end

  def current_peace(other_house)
    DiplomaticRelation.with(self).of(other_house).category(DiplomaticRelation::PEACE).pending.last
  end

  def current_alliance(other_house)
    DiplomaticRelation.with(self).of(other_house).category(DiplomaticRelation::ALLY).pending.last
  end

  def current_allegiance(other_house)
    DiplomaticRelation.with(self).of(other_house).category(DiplomaticRelation::LIEGE).pending.last
  end

  def diplomatic_offers
    @diplomatic_offers ||= DiplomaticRelation.offered(self)
  end

  def declare_war!(other_house)
    cb = cassus_belli(other_house)
    return false unless cb && !at_war?(other_house)
    cb.declare_war!(baron)
  end

  def at_war?(other_house)
    return false unless other_house
    other_house.ancient? || DiplomaticRelation.has_relations?(self,other_house,DiplomaticRelation::WAR)
  end

  def offer_truce!(other_house,tokens=[])
    return unless at_war?(other_house)
    return if other_house.ancient?
    current_war(other_house).offer_truce!(self.baron,tokens)
  end

  def offer_peace!(other_house,tokens=[])
    return unless at_war?(other_house)
    return if other_house.ancient?
    current_war(other_house).offer_peace!(self.baron,tokens)
  end

  def wars
    return @wars if @wars
    list = DiplomaticRelations.of(self).category(DiplomaticRelation::WAR)
    @wars = list.map{|rel|rel.target}
  end

  def offer_alliance!(other_house,tokens=[])
    return if other_house.ancient?
    DiplomaticRelation.create_relation!(self,other_house,baron,DiplomaticRelation::ALLY,nil,tokens)
  end

  def ally?(other_house)
    DiplomaticRelation.has_relations?(self,other_house,DiplomaticRelation::ALLY)
  end

  def oath_of_allegiance!(other_house,tokens=[])
    return if other_house.ancient?
    DiplomaticRelation.create_relation!(self,other_house,baron,DiplomaticRelation::LIEGE,nil,tokens)
  end

  def vassal?(other_house)
    DiplomaticRelation.has_relations?(self,other_house,DiplomaticRelation::LIEGE)
  end

  def liege_of?(other_house)
    DiplomaticRelation.has_relations?(self,other_house,DiplomaticRelation::VASSAL)
  end

  def break_oath!(other_house=liege)
    return if other_house.ancient?
    raise false unless other_house
    if vassal?(other_house)
      DiplomaticRelation.remove_relation!(self,other_house,DiplomaticRelation::LIEGE)
      DiplomaticRelation.remove_relation!(other_house,self,DiplomaticRelation::VASSAL,false)
    else
      DiplomaticRelation.remove_relation!(self,other_house,DiplomaticRelation::VASSAL)
      DiplomaticRelation.remove_relation!(other_house,self,DiplomaticRelation::LIEGE,false)
    end
    DiplomaticRelation.create_relation!(self,other_house,self.baron,DiplomaticRelation::WAR,DiplomaticRelation::BROKE_OATH)
    update_attributes!(:honour => 0)
  end

  def break_alliance!(other_house,attacking=false)
    return if other_house.ancient?
    DiplomaticRelation.remove_relation!(self,other_house,DiplomaticRelation::ALLY)
    update_attributes!(:honour => (self.honour * 0.5).round(0).to_i) if attacking
  end

  def break_truce!(other_house)
    return if other_house.ancient?
    declare_war!(other_house)
    update_attributes!(:honour => (self.honour * 2.5).round(0).to_i)
  end

  def send_message(to,subject,content)
    Message.send!(to, self.baron, subject, content)
  end

  def imprisoned_members
    @imprisoned_members ||= Character.of_house(self).prisoner
  end

  def add_honour!(amount)
    update_attributes!(:honour => self.honour + amount)
  end

  def lose_honour!(amount)
    update_attributes!(:honour => self.honour - amount)
  end

  def add_glory!(amount)
    update_attributes!(:glory => self.glory + amount)
  end

  def lose_glory!(amount)
    update_attributes!(:glory => self.glory - amount)
  end

  def add_piety!(amount)
    update_attributes!(:piety => self.piety + amount)
  end

  def lose_piety!(amount)
    update_attributes!(:piety => self.piety - amount)
  end

  def tidy_relations!
    self.diplomatic_relations.each do |rel|
      rel.destroy if rel.target.nil? || !rel.target.active?
    end
  end

  def cease!(noble_house=nil)
    # move all funds, estates, armies, ships and character to the new noble house
    transaction do
      new_baron = noble_house.baron if noble_house
      self.player.deliver_house_ceased!(new_baron) if self.player
      if self.baron
        self.baron.titles.each{|title| title.revoke! } 
      end
      if noble_house
        transfer_funds!(noble_house,self.wealth)
        self.estates.each{|estate| estate.update_attributes!(:noble_house_id => noble_house.id)}
        self.starships.each{|starship| starship.update_attributes!(:noble_house_id => noble_house.id)}
        self.armies.each{|army| army.update_attributes!(:noble_house_id => noble_house.id)}
        self.characters.each{|character| character.update_attributes!(:noble_house_id => noble_house.id) if character.alive?}
      else
        self.characters.each{|character| character.leave! if character.alive?}
        self.estates.destroy_all
        self.starships.destroy_all
        self.armies.destroy_all
      end
      self.diplomatic_relations.destroy_all
      self.titles.destroy_all
      self.authorisations.destroy_all
      self.market_items.destroy_all
      update_attributes!(:active => false, :player_id => nil)
      Character.move_out_of_limbo!
      add_empire_news!("CEASED")
    end
  end

  def floor_attributes
    self.honour = 0 if self.honour < 0
    self.piety = 0 if self.piety < 0
    self.glory = 0 if self.glory < 0
  end

  def automated_appointments!(skilled=true,roles={:steward => true, :tribune => true, :legate => true, :captain => true, :chancellor => true})
    reload
    if roles[:steward] || roles[:tribune]
      self.estates.each do |estate|
        if roles[:steward] && (estate.steward.nil? || estate.steward.dead?)
          list = Character.potential_candidates(estate, Title::STEWARD, skilled)
          list.first.add_title!(Title::STEWARD,estate) if list.size > 0
        end
        if roles[:tribune] && (estate.tribune.nil? || estate.tribune.dead?)
          list = Character.potential_candidates(estate, Title::TRIBUNE, skilled)
          list.first.add_title!(Title::TRIBUNE,estate) if list.size > 0
        end
      end 
    end
    # if roles[:legate]
    #   self.armies.each do |army|
    #     if army.legate.nil? || army.legate.dead?
    #       list = Character.potential_candidates(army, Title::LEGATE, skilled)
    #       if list.size > 0
    #         c = list.first
    #         c.add_title!(Title::LEGATE,army) 
    #         c.location = army
    #         c.save
    #       end
    #     end
    #   end 
    # end
    # if roles[:captain]
    #   self.starships.each do |starship|
    #     if starship.captain.nil? || starship.captain.dead?
    #       list = Character.potential_candidates(starship, Title::LEGATE, skilled)
    #       if list.size > 0
    #         starship.embark_character!(list.first)
    #       end
    #     end
    #   end 
    # end
    if roles[:chancellor] && (self.chancellor.nil? || self.chancellor.dead?)
      list = Character.potential_candidates(self, Title::CHANCELLOR, skilled)
      list.first.add_title!(Title::CHANCELLOR,self) if list.size > 0
    end
  end

  private
  def validate_signup
    errors.add(:name, "does not need to contain the word House") if !self.name.blank? && self.name.downcase.include?('house')
    errors.add(:patriarch, "must be named") if self.patriarch.blank?
    errors.add(:matriarch, "must be named") if self.matriarch.blank?
    errors.add(:patriarch_skills, "must be chosen") if self.patriarch_skill1.blank? || self.patriarch_skill2.blank? || self.patriarch_skill3.blank?
    errors.add(:matriarch_skills, "must be chosen") if self.matriarch_skill1.blank? || self.matriarch_skill2.blank? || self.matriarch_skill3.blank?
    errors.add(:first_child, "must be named") if self.first_child_name.blank?
    errors.add(:second_child, "must be named") if self.second_child_name.blank?
    errors.add(:third_child, "must be named") if self.third_child_name.blank?
    errors.add(:first_child, "must be given a skill") if self.first_child_skill.blank?
    errors.add(:second_child, "must be given a skill") if self.second_child_skill.blank?
    errors.add(:third_child, "must be given a skill") if self.third_child_skill.blank?
    errors.add(:estate, "must be named") if self.estate_name.blank?
    errors.add(:region, "must be chosen") if self.region.blank?
  end

  def signup?
    new_record? && !ancient?
  end
end

