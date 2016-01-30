class Building < ActiveRecord::Base
  attr_accessible :estate, :building_type, :level, :build_date, :upgraded_date, :capacity_used
  
  DEMOLISH_RECLAIM_MODIFIER = 0.25

  after_save  :estate_set_totals
  
  belongs_to :estate
  belongs_to :building_type
  validates_numericality_of :level, :only_integer => true
  game_date :build_date
  game_date :upgraded_date
  validates_numericality_of :capacity_used, :only_integer => true

  scope :at, lambda {|estate|
    {:conditions => {:estate_id => estate.id}, :include => :building_type}
  }

  scope :building_type, lambda {|building_type|
    {:conditions => {:building_type_id => building_type.id}, :include => :building_type}
  }

  scope :of_types, lambda {|building_types|
    {:conditions => ["building_type_id IN (?)", building_types], :include => :building_type}
  }

  def self.reset_building_capacities!
    update_all(:capacity_used => 0)
  end

  def self.building_level(estate,building_type)
    list = at(estate).building_type(building_type)
    list.size < 1 ? 0 : list.first.level
  end

  def self.sum_tithe_modifier(estate)
    total = 0
    at(estate).of_types(BuildingType.tithing).each{|building| total += building.tithe_modifier}
    total
  end

  def self.sum_production_capacity(estate)
    total = 0
    at(estate).of_types(BuildingType.production).each{|building| total += building.production_capacity}
    total
  end

  def self.sum_shuttle_capacity(estate)
    total = 0
    at(estate).of_types(BuildingType.shuttles).each{|building| total += building.shuttle_capacity}
    total
  end

  def self.sum_shuttle_capacity_used(estate)
    total = 0
    at(estate).of_types(BuildingType.shuttles).each{|building| total += building.capacity_used}
    total
  end

  def self.build!(estate, building_type,skip_materials=false)
    # puts "BUILD: #{estate.name} - #{building_type.category} - has space? #{estate.has_space?}"
    return false unless estate.has_space?
    # puts "Has space"
    return false unless skip_materials || building_type.position_has_raw_materials_for(estate) > 0
    # puts "Has raw materials"
    return false unless building_type.max_building_level(estate.region) > building_level(estate,building_type)
    # puts "Max building level OK"
    list = at(estate).building_type(building_type)
    # puts "BUILD: Good"
    transaction do
      # puts "Transaction start"
      building = list.size > 0 ? list.first : create!(:estate => estate, :building_type => building_type, :build_date => Game.current_date)
      # puts "Building: #{building.id}"
      building.level += 1
      building.upgraded_date = Game.current_date
      building.save!
      unless skip_materials
        cost_multiplier = 1.0 - (estate.effective_engineering * 0.1)
        building_type.position_remove_raw_materials!(estate,cost_multiplier)
      end
      building
    end
  end

  def estate_set_totals
    self.estate.set_totals if self.estate
  end

  def demolish!(levels=1)
    levels = self.level if levels > self.level
    transaction do
      levels.times do
        self.building_type.raw_materials.each do |ib|
          self.estate.add_item!(ib.item, (ib.quantity * DEMOLISH_RECLAIM_MODIFIER).round(0).to_i)
        end
      end
      self.level -= levels
      self.level < 1 ? destroy : save!
    end
    levels
  end

  def workers_needed_by_type
    ret = {}
    Item::WORKER_TYPES.each do |worker_type|
      ret[worker_type] = self.building_type.workers_required(worker_type) * self.level unless worker_type == Item::NONE
    end
    ret
  end

  def count_workers_needed(worker_type)
    return @workers_needed[worker_type] if @workers_needed && @workers_needed[worker_type]
    @workers_needed = {} unless @workers_needed
    @workers_needed[worker_type] = self.building_type.workers_required(worker_type) * self.level
  end

  def shuttle_capacity
    @shuttle_capacity ||= (self.building_type.shuttle_capacity * self.level * self.estate.efficiency_for(self.building_type)).to_i
  end

  def production_capacity
    @production_capacity ||= (self.building_type.production_capacity * self.level * self.estate.efficiency_for(self.building_type)).to_i
  end

  def ship_hulls_assembled
    @ship_hulls_assembled ||= (self.building_type.ship_hulls_assembled * self.level * self.estate.efficiency_for(self.building_type)).to_i
  end

  def tithe_modifier
    @tithe_modifier ||= (self.building_type.tithe_modifier * self.level * self.estate.efficiency_for(self.building_type)).to_i
  end

  def items_harvested
    @items_harvested ||= Item.source(world).category(Item::TRADE_GOOD).trade_good(self.building_type.trade_good_type)
  end

  def resources_gathering_items(next_rotation=false)
    return {} unless self.building_type.resource_gathering? && self.estate.steward
    return @resources_gathering_items if @resources_gathering_items && !next_rotation
    return @resources_gathering_items_next_rotation if @resources_gathering_items_next_rotation && next_rotation
    if self.building_type.item_produced
      resource_yield = if next_rotation
        self.estate.region.next_rotation_resource_yield(self.building_type.item_produced)
      else
        self.estate.region.current_resource_yield(self.building_type.item_produced)
      end
      qty = (resource_yield * self.level * self.estate.efficiency_for(self.building_type)).to_f.round(0).to_i
      return @resources_gathering_items_next_rotation = {self.building_type.item_produced => qty} if next_rotation
      return @resources_gathering_items = {self.building_type.item_produced => qty}
    else
      p = {}
      items_harvested.each do |item|
        resource_yield = if next_rotation
          self.estate.region.next_rotation_resource_yield(item)
        else
          self.estate.region.current_resource_yield(item)
        end
        p[item] = (resource_yield * self.level * self.estate.efficiency_for(self.building_type)).to_f.round(0).to_i
      end
      return @resources_gathering_items_next_rotation = p if next_rotation
      return @resources_gathering_items = p
    end
  end

  def recruitment_items
    return {} unless self.building_type.recruitment? && self.estate.tribune
    return @recruitment_items if @recruitment_items
    qty = (self.building_type.item_produced_quantity * self.level * self.estate.efficiency_for(self.building_type)).to_f.round(0).to_i
    unless self.building_type.recruitment_type.blank?
      item = Item.source(self.estate.region.world).worker(self.building_type.recruitment_type).first
    else
      item = self.building_type.item_produced
    end
    @recruitment_items = {item => qty}
  end

  def expected_production
    return @expected_production if @expected_production
    produced_items = if self.building_type.resource_gathering?
      resources_gathering_items(true)
    elsif self.building_type.recruitment?
      recruitment_items
    else
      []
    end
    @expected_production = produced_items.to_a.map{|item,quantity| "#{quantity} x #{item.name}" unless quantity == 0}.join(", ")
  end

  def gather_resources!
    return false unless self.building_type.resource_gathering?
    total_quantity = 0
    if self.building_type.item_produced
      quantity = (self.estate.region.current_resource_yield(self.building_type.item_produced) * self.level * self.estate.efficiency_for(self.building_type)).to_f.round(0).to_i
      item = self.building_type.item_produced
      if quantity > 0
        total_quantity += quantity
        self.estate.add_item!(item, quantity)
        self.estate.add_news!("MINING","#{quantity} x #{item.name.pluralize_if(quantity)}")
      end
    else
      items_harvested.each do |item|
        quantity = (self.estate.region.current_resource_yield(item) * self.level * self.estate.efficiency_for(self.building_type)).to_f.round(0).to_i
        if quantity > 0
          total_quantity += quantity
          self.estate.add_item!(item, quantity)
          self.estate.add_news!("HARVESTING","#{quantity} x #{item.name.pluralize_if(quantity)}")
        end
      end
    end
    total_quantity
  end

  def recruit!
    return unless self.building_type.recruitment?
    quantity = (self.building_type.item_produced_quantity * self.level * self.estate.efficiency_for(self.building_type)).to_f.round(0).to_i
    if self.building_type.item_produced
      item = self.building_type.item_produced
      if quantity > 0
        self.estate.add_item!(item, quantity)
        self.estate.add_news!("RECRUIT_TROOP","#{quantity} x #{item.name.pluralize_if(quantity)}")
      end
    elsif self.building_type.recruitment_type
      Population.add_population!(self.estate, self.building_type.recruitment_type, quantity)
      self.estate.add_news!("RECRUIT_WORKER","#{quantity} x #{self.building_type.recruitment_type.pluralize_if(quantity)}")
    end
  end

  private
  def world
    @world ||= self.estate.region.world
  end
end
