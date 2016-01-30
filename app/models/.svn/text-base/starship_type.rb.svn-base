class StarshipType < ActiveRecord::Base
  attr_accessible :name, :hull_type, :hull_size, :project_required

  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :hull_type, :class_name => 'Item'
  validates_numericality_of :hull_size, :only_integer => true
  validates_inclusion_of :project_required, :in => Item::VALID_PRIJECT_TYPES

  has_many :starships, :dependent => :destroy

  scope :hull_type, lambda {|item|
    {:conditions => {:hull_type_id => item.id}}
  }

  scope :project, lambda {|project|
    {:conditions => {:project_required => project.category}}
  }

  def self.define!(name, hull_type, hull_size, project_required = '')
    create!(:name => name, :hull_type => hull_type, :hull_size => hull_size, :project_required => project_required)
  end

  def armour_slots
    @armour_slots ||= (self.hull_type.armour_slots * self.hull_size).to_i
  end

  def command_slots
    @command_slots ||= self.hull_type.command_slots
  end
  
  def mission_slots
    @mission_slots ||= (self.hull_type.mission_slots * self.hull_size).to_i
  end

  def engine_slots
    @engine_slots ||= (self.hull_type.engine_slots * self.hull_size).to_i
  end

  def utility_slots
    @utility_slots ||= (self.hull_type.utility_slots * self.hull_size).to_i
  end

  def primary_slots
    @primary_slots ||= (self.hull_type.primary_slots * self.hull_size).to_i
  end

  def spinal_slots
    @spinal_slots ||= (self.hull_type.spinal_slots * self.hull_size).to_i
  end

  def max_hull_points
    @max_hull_points ||= (self.hull_type.hull_points * self.hull_size)
  end

  def can_build?(estate)
    return false unless estate.can_build_ships?
    world = estate.region.world
    self.project_required.blank? ? true : world.has_project?(self.project_required)
  end

  def jammer_modifier
    return @jammer_modifier if @jammer_modifier
    return @jammer_modifier = -3 if self.hull_size >= 200
    return @jammer_modifier = -2 if self.hull_size >= 100
    return @jammer_modifier = -1 if self.hull_size >= 50
    @jammer_modifier = 0
  end

  def restricted?
    @restricted ||= !self.project_required.blank?
  end

  def configuration
    @configuration ||= calculate_configuration
  end

  def configuration_to_s
    @configuration_string ||= configuration.map { |key,value| [value, key].join(" x ") if value > 0 }.compact.join(", ")
  end

  def calculate_configuration
    parts = Hash.new
    parts['Armour'] = armour_slots
    parts['Command'] = command_slots
    parts['Mission'] = mission_slots
    parts['Engine'] = engine_slots
    parts['Utility'] = utility_slots
    parts['Primary Weapon'] = primary_slots
    parts['Spinal Mount'] = spinal_slots
    parts
  end

  def ore_costs
    costs = {}
    self.hull_type.raw_materials{|ib| costs[ib.item] = (ib.quantity) * self.hull_size}
    costs
  end

  def ore_costs_pp
    ore_costs.keys.map{|item| "#{ore_costs[item]} x #{item.name}"}
  end
end
