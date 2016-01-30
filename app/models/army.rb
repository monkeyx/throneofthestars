class Army < ActiveRecord::Base
  attr_accessible :guid, :noble_house, :name, :location, :location_type, :location_id, :legate, :morale, :legate_id
  
  before_save :generate_guid
  before_save :calculate_movement_type

  self.per_page = 15

  ORBITAL_MOVE_COST = 4
  AIR_MOVE_COST = 6
  GROUND_MOVE_COST = 8
  LOGISTICS_COST_MODIFIER = 1

  validates_presence_of :name
  belongs_to :noble_house
  scope :of, lambda {|house|
    {:conditions => {:noble_house_id => house.id}}
  }

  belongs_to :legate, :class_name => 'Character'
  validates_numericality_of :morale

  has_many :units, :dependent => :destroy

  scope :at, lambda {|location|
    {:conditions => {:location_type => location.class.to_s, :location_id => location.id}}
  }

  include Locatable
  include Wealthy::NobleHousePosition
  include NewsLog
  include HousePosition

  def self.create_army!(name, estate, legate=nil)
    army = create!(:name => name, :noble_house => estate.noble_house, :legate => legate)
    army.location = estate
    army.save!
    army.add_news!("ARMY_FORMED",estate.lord)
    Title.appoint_legate!(legate, army) if legate
    army
  end

  def create_unit!(name,item,quantity,knight=nil)
    unit = self.units.create!(:name => name, :knight => knight)
    unit.add_item!(item,quantity)
    add_news!("UNIT_FORMED",unit)
    unit
  end

  def killed!
    # characters with army are captured or killed
    if current_estate
      Prisoner.imprison!(army.legate,current_estate)
      self.units.each do |unit|
        Character.at(unit).each do |c|
          Prisoner.imprison!(c,current_estate)
        end
      end
    else
      army.legate.die!
      self.units.each do |unit|
        Character.at(unit).each do |c|
          c.die!("defeat in battle")
        end
      end
    end
    add_news!('ARMY_KILLED')
    destroy
  end

  def atttack_house_armies!(house)
    return false unless house
    return false unless self.noble_house.at_war?(house)
    return false unless (self.location_region? || self.location_estate?)
    armies = Army.at(self.location).of(house)
    return false if armies.empty?
    armies.each{|army| battle = attack!(army); return true if battle.attacker_lost? }
    true
  end

  def attack!(army)
    return false unless same_location?(army) || at_same_estate?(army)
    add_empire_news!("ATTACK_ARMY",army)
    GroundBattle.fight!(self,army)
  end

  def assault!(estate)
    return false unless at_same_estate?(estate) && estate.noble_house_id != self.noble_house_id
    armies = Army.at(estate).of(estate.noble_house)
    armies.each{|army| battle = attack!(army); return true if battle.attacker_lost? }
    add_empire_news!("ASSAULT_ESTATE",estate)
    GroundBattle.fight!(self,estate)
  end

  def movement_type
    @movement_type ||= calculate_movement_type
  end

  def calculate_movement_type
    ground_total = 0
    air_total = 0
    orbital_total = 0
    empty_total = 0
    self.units.each do |unit|
      ground_total += 1 if unit.ground?
      air_total += 1 if unit.air?
      orbital_total += 1 if unit.orbit?
      empty_total += 1 if unit.empty?
    end
    @movement_type = nil
    size = units.size - empty_total 
    if orbital_total == size
      @movement_type = "Orbital"
    elsif air_total == size
      @movement_type = "Air"
    elsif ground_total == size
      @movement_type = "Ground"
    end
    @movement_type
  end

  def sum_mass_categories(item_categories)
    self.units.sum{|unit| unit.sum_mass_categories(item_categories)}
  end

  def sum_mass_category(category)
    self.units.sum{|unit| unit.sum_mass_category(category)}
  end

  def embarkation_cargo_space
    @embarkation_cargo_space ||= sum_mass_categories(Item::CARGO)
  end

  def total_troops
    @total_troops ||= sum_mass_category(Item::TROOP)
  end

  def legate_and_knights
    leaders = [self.legate]
    self.units.each{|unit| leaders << unit.knight if unit.knight}
    leaders
  end

  def effective_medicine
    Skill.best_skill(legate_and_knights, Skill::CHURCH_MEDICINE)
  end

  def effective_tactics
    Skill.best_skill(legate_and_knights,Skill::MILITARY_TACTICS)
  end

  def effective_reconnaissance
    Skill.best_skill(legate_and_knights,Skill::MILITARY_RECON)
  end

  def effective_fortification
    Skill.best_skill(legate_and_knights,Skill::MILITARY_FORTIFICATIONS)
  end

  def effective_explosives
    Skill.best_skill(legate_and_knights,Skill::MILITARY_EXPLOSIVES)
  end

  def effective_leadership
    Skill.best_skill(legate_and_knights,Skill::MILITARY_LEADERSHIP)
  end

  def effective_morale
    self.morale + (effective_leadership * 10)
  end

  def pay_wages!
    wages_required = total_troops
    wages_to_pay = wealth < wages_required ? wealth : wages_required
    subtract_wealth!(wages_to_pay)
    if wages_to_pay < wages_required
      self.morale -= ((wages_to_pay / wages_required.to_f) * 100.0)
      save!
    end
    add_news!("PAY_TROOPS","#{money(wages_to_pay)} to #{wages_required} troops") if wages_required > 0
  end

  def chronum_morale_adjustments!
    if self.location_estate? && self.location.same_house?(self)
      self.morale += 10
    end
    self.morale += (self.noble_house.honour * 0.01)
    self.morale = 100 if self.morale > 100
    if self.morale <= 20
      roll = "1d20".roll
      if roll >= self.morale
        self.units.each do |unit|
          troops = ItemBundle.at(unit).of_type(Item::TROOP)
          troops.each do |ib|
            qty = (ib.quantity * 0.25).round(0).to_i
            if qty > 0
              ib.quantity = ib.quantity - qty
              ib.save
              add_news!('DESERTION',"#{qty} x #{ib.item.name}")
            end
          end
        end
      end
    end
    save!
  end

  def orbital_allowed?
    @orbital_allowed ||= movement_type == "Orbital"
  end

  def movement_allowed?
    @movement_allowed ||= !movement_type.nil?
  end

  def adjusted_movement_cost
    return @adjusted_movement_cost if @adjusted_movement_cost
    @adjusted_movement_cost = movement_cost
    logistics_rank = Skill.skill_rank(self.legate,Skill::MILITARY_LOGISTICS)
    @adjusted_movement_cost -= (logistics_rank * LOGISTICS_COST_MODIFIER)
    @adjusted_movement_cost = 0 if @adjusted_movement_cost < 0
    @adjusted_movement_cost
  end

  def movement_cost
    return ORBITAL_MOVE_COST if movement_type == "Orbital"
    return AIR_MOVE_COST if movement_type == "Air"
    return GROUND_MOVE_COST if movement_type == "Ground"
    0
  end

  def move!(region_or_estate=nil)
    return unless movement_allowed?
    if region_or_estate
      self.location = region_or_estate
    elsif orbital_allowed?
      self.location = current_world
    end
    save!
    add_news!("ARMY_MOVE",self.location)
    self.location
  end
end