class Unit < ActiveRecord::Base
  attr_accessible :name, :army, :knight
  
  after_save  :calculate_army_movement

  MAX_UNIT_MASS = 10000
  validates_presence_of :name
  belongs_to :army
  belongs_to :knight, :class_name => 'Character'

  scope :of_house, lambda {|house|
    {:conditions => ["army_id IN (?)", house.armies]}
  }

  scope :of, lambda {|army|
    {:conditions => {:army_id => army.id}}
  }

  scope :by_id, lambda {|id|
    {:conditions => {:id => id}}
  }

  include ItemContainer

  def assign_knight!(character)
    return false unless character && character.knight? && self.knight.nil?
    self.knight = character
    save!
    self.army.add_news!('LEAD_UNIT',"#{self.name} is being led by #{character.display_name}")
    character.join_unit!(self)
    true
  end

  def category_allowed?(category)
    return false unless Item::MILITARY.include?(category)
    return true if empty?
    return true if total_aircraft > 0 && category == Item::AIRCRAFT
    return true if total_ordinance > 0 && category == Item::ORDINANCE
    true
  end

  def space_available(category)
    if category_allowed?(category)
      MAX_UNIT_MASS
    else
      0
    end
  end

  def total_troops
    @total_troops ||= sum_category_quantity(Item::TROOP)
  end

  def total_aircraft
    @total_aircraft ||= sum_category_quantity(Item::AIRCRAFT)
  end

  def total_tanks
    @total_tanks ||= sum_category_quantity(Item::TANK)
  end

  def total_ordinance
    @total_ordinance ||= sum_category_quantity(Item::ORDINANCE)
  end

  def total_transports
    @total_transports ||= sum_category_quantity(Item::TRANSPORT)
  end

  def transport_capacity
    @transport_capacity ||= sum_item_attributes(:transport_capacity)
  end

  def transport_required
    @transport_required ||= sum_qualified_item_attributes(:ground_movement_only?, :mass)
  end

  def ground?
    @ground ||= distinct_item_attributes(:movement).include?(Item::MOVEMENT_GROUND)
  end

  def air?
    @air ||= orbit? || transported_movement?(Item::MOVEMENT_AIR)
  end

  def orbit?
    @orbit ||= transported_movement?(Item::MOVEMENT_ORBIT)
  end

  def movement_types
    @movement_types ||= calculate_movement_types
  end

  def calculate_army_movement
    self.army.calculate_movement_type
  end

  private
  def transported_movement?(movement_type)
    distinct_item_attributes(:movement).include?(movement_type) && transport_required <= transport_capacity
  end

  def calculate_movement_types
    list = []
    list << "Ground" if ground?
    list << "Air" if air?
    list << "Orbital" if orbit?
    list
  end
end

