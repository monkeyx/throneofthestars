class StarshipConfiguration < ActiveRecord::Base
  attr_accessible :starship_type, :noble_house, :name, :starship_type_id, :noble_house_id

  self.per_page = 15

  belongs_to  :starship_type
  belongs_to  :noble_house
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :starship_configuration_items

  include Starships

  scope :for_house, lambda {|house|
    {:conditions => ["noble_house_id IS NULL or noble_house_id = 0 OR noble_house_id = ?", house.id],
    :order => "name ASC"
    }
  }

  scope :public,
    :conditions => "noble_house_id IS NULL or noble_house_id = 0",
    :order => "name ASC"

  scope :for_type, lambda {|starship_type|
    {:conditions => {:starship_type_id => starship_type.id},
      :order => "name ASC"
    }
  }

  scope :corvette, :conditions => {:name => 'Corvette'}
  scope :courier, :conditions => {:name => 'Courier'}
  scope :ranger, :conditions => {:name => 'Ranger'}
  scope :guildsman, :conditions => {:name => 'Guildsman'}
  scope :imperial_transport, :conditions => {:name => 'Imperial Transport'}
  scope :imperial_cruiser, :conditions => {:name => 'Imperial Cruiser'}
  scope :ship_of_the_line, :conditions => {:name => 'Ship of the Line'}

  def self.create_configuration!(name,starship_type,house=nil)
    create!(:name => name, :starship_type => starship_type, :noble_house => house)
  end

  def count_section(item)
    sci = StarshipConfigurationItem.find_by_starship_configuration_id_and_item_id(self.id, item.id)
    sci.nil? ? 0 : sci.quantity
  end

  def add_sections!(item, quantity=1)
    max_install = has_space_for(item)
    quantity = max_install if quantity > max_install
    return 0 if quantity < 1
    sci = StarshipConfigurationItem.find_or_create_by_starship_configuration_id_and_item_id(self.id, item.id)
    qty = sci.quantity ? sci.quantity + quantity : quantity
    sci.update_attributes!(:quantity => qty)
    qty
  end

  def remove_sections!(item, quantity=count_section(item))
    sci = StarshipConfigurationItem.find_by_starship_configuration_id_and_item_id(self.id, item.id)
    return 0 if sci.nil?
    if sci.quantity > quantity
      sci.update_attributes!(:quantity => sci.quantity - quantity)
    else
      sci.destroy
    end
    sci.quantity
  end

  def update_sections!(item, quantity)
    sci = StarshipConfigurationItem.find_or_create_by_starship_configuration_id_and_item_id(self.id, item.id)
    max_install = has_space_for(item)
    max_install += sci.quantity
    quantity = max_install if max_install < quantity
    if quantity < 1
      sci.destroy
    else
      sci.update_attributes!(:quantity => quantity)
    end
    quantity
  end

  def slots_used
    @slots ||= calculate_slots_used
  end

  def weapon_slots_used
    @weapon_slots_used ||= slots_used[Item::LAUNCHER] + slots_used[Item::BEAM_WEAPON] + slots_used[Item::KINETIC_WEAPON]
  end

  def calculate_slots_used
    @slots = {}
    @slots[Item::ARMOUR] = 0
    @slots[Item::COMMAND] = 0
    @slots[Item::MISSION] = 0
    @slots[Item::ENGINE] = 0
    @slots[Item::UTILITY] = 0
    @slots[Item::LAUNCHER] = 0
    @slots[Item::BEAM_WEAPON] = 0
    @slots[Item::KINETIC_WEAPON] = 0
    @slots[Item::SPINAL_MOUNT] = 0
    self.starship_configuration_items.each do |sci|
      qty = @slots[sci.item.category]
      qty = 0 unless qty
      qty += sci.quantity
      @slots[sci.item.category] = qty
    end
    @slots
  end

  def has_space_for(item)
    return case item.category
    when Item::ARMOUR
      self.starship_type.armour_slots - slots_used[Item::ARMOUR]
    when Item::COMMAND
      self.starship_type.command_slots - slots_used[Item::COMMAND]
    when Item::MISSION
      self.starship_type.mission_slots - slots_used[Item::MISSION]
    when Item::ENGINE
      self.starship_type.engine_slots - slots_used[Item::ENGINE]
    when Item::UTILITY
      self.starship_type.utility_slots - slots_used[Item::UTILITY]
    when Item::LAUNCHER
      self.starship_type.primary_slots - weapon_slots_used
    when Item::BEAM_WEAPON
      self.starship_type.primary_slots - weapon_slots_used
    when Item::KINETIC_WEAPON
      self.starship_type.primary_slots - weapon_slots_used
    when Item::SPINAL_MOUNT
      self.starship_type.spinal_slots - slots_used[Item::SPINAL_MOUNT]
    else
      0
    end
  end

  def configuration(refresh=false)
    @configuration = nil if refresh
    @configuration ||= calculate_configuration
  end

  def calculate_configuration
    parts = Hash.new
    parts['Armour'] = "#{slots_used[Item::ARMOUR]} / #{self.starship_type.armour_slots}"
    parts['Command'] = "#{slots_used[Item::COMMAND]} / #{self.starship_type.command_slots}"
    parts['Mission'] = "#{slots_used[Item::MISSION]} / #{self.starship_type.mission_slots}"
    parts['Engine'] = "#{slots_used[Item::ENGINE]} / #{self.starship_type.engine_slots}"
    parts['Utility'] = "#{slots_used[Item::UTILITY]} / #{self.starship_type.utility_slots}" if self.starship_type.utility_slots > 0
    parts['Primary Weapon'] = "#{weapon_slots_used} / #{self.starship_type.primary_slots}" if self.starship_type.primary_slots > 0
    parts['Spinal Mount'] = "#{slots_used[Item::SPINAL_MOUNT]} / #{self.starship_type.spinal_slots}" if self.starship_type.spinal_slots > 0
    parts
  end

  def metrics
    calculate_metrics(self.starship_configuration_items)
  end

  def ore_costs
    costs = starship_type.ore_costs
    self.starship_configuration_items.each do |section|
      section.item.raw_materials.each do |ib|
        count = costs[ib.item]
        count = 0 unless count
        count += (ib.quantity * section.quantity)
        costs[ib.item] = count
      end
    end
    costs
  end

  def ore_costs_pp
    ore_costs.keys.map{|item| "#{ore_costs[item]} x #{item.name}"}
  end
end
