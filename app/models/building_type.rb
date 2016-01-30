class BuildingType < ActiveRecord::Base
  attr_accessible :category, :worker_type, :workers_needed, :item_produced, :trade_good_type, :recruitment_type, :item_produced_quantity

  self.per_page = 8  

  PALACE = "Palace"
  MINE = "Mine"
  FORGE = "Forge"
  REFINERY = "Refinery"
  REACTOR = "Reactor"
  FARM = "Farm"
  RANCH = "Ranch"
  FISHERY = "Fishery"
  HUNTING_LODGE = "Hunting Lodge"
  WEAVERS = "Weavers"
  SILK_FARM = "Silk Farm"
  MEADERY = "Meadery"
  BREWERY = "Brewery"
  VINEYARD = "Vineyard"
  TRADE_HALL = "Trade Hall"
  SHUTTLE_PORT = "Shuttle Port"
  ORBITAL_DOCK = "Orbital Dock"
  COLLEGE = "College"
  BARRACKS = "Barracks"
  ACADEMY = "Academy"
  CHAPEL = "Chapel"
  CHURCH = "Church"
  CATHEDRAL = "Cathedral"
  WORKSHOP = "Workshop"
  SHIPYARD = "Shipyard"
  FACTORY = "Factory"
  HOSPITAL = "Hospital"
  UNIVERSITY = "University"

  RECRUITMENT_BUILDINGS = [TRADE_HALL, COLLEGE, BARRACKS, ACADEMY, UNIVERSITY]
  TRADE_GOOD_BUILDINGS = [FARM, RANCH,FISHERY,HUNTING_LODGE,WEAVERS,SILK_FARM,MEADERY,BREWERY,VINEYARD]
  ORE_BUILDINGS = [MINE,FORGE,REFINERY,REACTOR]
  TRADE_BUILDINGS = [TRADE_HALL,SHUTTLE_PORT,ORBITAL_DOCK]

  PRODUCTION_CAPACITY = {WORKSHOP => 50, FACTORY => 250}

  BUILDING_TYPES = [PALACE,
    MINE,FORGE,REFINERY,REACTOR,
    FARM,RANCH,FISHERY,
    HUNTING_LODGE,WEAVERS,SILK_FARM,
    MEADERY,BREWERY,VINEYARD,
    TRADE_HALL,SHUTTLE_PORT,ORBITAL_DOCK,
    COLLEGE,BARRACKS,ACADEMY,
    CHAPEL,CHURCH,CATHEDRAL,
    WORKSHOP,SHIPYARD,
    FACTORY,HOSPITAL,UNIVERSITY]

  validates_inclusion_of :category, :in => BUILDING_TYPES

  validates_inclusion_of :worker_type, :in => Item::WORKER_TYPES
  validates_numericality_of :workers_needed, :only_integer => true

  belongs_to :item_produced, :class_name => 'Item'
  validates_numericality_of :item_produced_quantity, :only_integer => true

  validates_inclusion_of :recruitment_type, :in => ([Item::NONE] + Item::WORKER_TYPES)
  validates_inclusion_of :trade_good_type, :in => Item::TRADE_GOOD_TYPES

  include RawMaterials

  scope :category, lambda {|category|
    {:conditions => {:category => category}}
  }

  scope :item_produced, lambda {|item_produced|
    {:conditions => {:item_produced_id => item_produced.id}}
  }

  scope :trade_good_type, lambda {|trade_good_type|
    {:conditions => {:trade_good_type => trade_good_type}}
  }

  scope :tithing, :conditions => ["category IN (?)", [CHAPEL, CHURCH, CATHEDRAL]]
  scope :shuttles, :conditions => ["category IN (?)", [SHUTTLE_PORT]]
  scope :production, :conditions => ["category IN (?)", [WORKSHOP]]

  def self.building_type(bt)
    category(bt).first
  end

  def self.create_civil!(category, worker_type,workers_quantity,raw_materials)
    b = create!(:category => category, :worker_type => worker_type, :workers_needed => workers_quantity)
    b.add_all_raw_materials!(raw_materials)
    b
  end

  def self.create_ore_gathering!(category, worker_type,workers_quantity,raw_materials,ore)
    b = create!(:category => category, :worker_type => worker_type, :workers_needed => workers_quantity,
      :item_produced => ore
    )
    b.add_all_raw_materials!(raw_materials)
    b
  end

  def self.create_trade_good_gathering!(category, worker_type,workers_quantity,raw_materials,trade_good_type)
    b = create!(:category => category, :worker_type => worker_type, :workers_needed => workers_quantity,
      :trade_good_type => trade_good_type
    )
    b.add_all_raw_materials!(raw_materials)
    b
  end

  def self.create_worker_recruitment!(category, worker_type,workers_quantity,raw_materials,recruitment_type,quantity)
    b = create!(:category => category, :worker_type => worker_type, :workers_needed => workers_quantity,
      :recruitment_type => recruitment_type, :item_produced_quantity => quantity
    )
    b.add_all_raw_materials!(raw_materials)
    b
  end

  def self.create_troop_recruitment!(category, worker_type,workers_quantity,raw_materials,troop,quantity)
    b = create!(:category => category, :worker_type => worker_type, :workers_needed => workers_quantity,
      :item_produced => troop, :item_produced_quantity => quantity
    )
    b.add_all_raw_materials!(raw_materials)
    b
  end

  def recruitment?
    @recruitment ||= RECRUITMENT_BUILDINGS.include?(self.category)
  end

  def ore?
    @ore ||= ORE_BUILDINGS.include?(self.category)
  end

  def trade_good?
    @trade_good ||= TRADE_GOOD_BUILDINGS.include?(self.category)
  end

  def resource_gathering?
    ore? || trade_good?
  end

  def collect_taxes?
    @collect_taxes ||= self.category == PALACE
  end

  def trade_hall?
    @trade_hall ||= self.category == TRADE_HALL
  end

  def hospital?
    @hospital ||= self.category == HOSPITAL
  end

  def workers_required(worker_type)
    return @workers_required[worker_type] if @workers_required && @workers_required[worker_type]
    @workers_required = {} unless @workers_required
    @workers_required[worker_type] = self.worker_type == worker_type ? self.workers_needed : 0
  end

  def shuttle_capacity
    @shuttle_capacity ||= self.category == SHUTTLE_PORT ? 1000 : 0
  end

  def production_capacity
    @production_capacity ||= (PRODUCTION_CAPACITY[self.category] ? PRODUCTION_CAPACITY[self.category] : 0)
  end

  def can_make_items?
    @can_make_items ||= production_capacity > 0
  end

  def ship_hulls_assembled
    @ship_hulls_assembled ||= self.category == SHIPYARD ? 5 : 0
  end

  def can_build_ships?
    @can_build_ships ||= ship_hulls_assembled > 0
  end

  def orbital_dock?
    @orbital_dock ||= self.category == ORBITAL_DOCK
  end

  def can_tithe?
    @can_tithe ||= self.category == CHAPEL
  end

  def can_join_clergy?
    @can_join_clergy ||= self.category == CHAPEL
  end

  def tithe_modifier
    return @tithe_modifier if @tithe_modifier
    return @tithe_modifier = 0.1 if self.category == CHURCH
    return @tithe_modifier = 0.25 if self.category == CATHEDRAL
    @tithe_modifier = 0
  end

  def max_building_level(region)
    return 1000 unless resource_gathering?
    if ore?
      item = self.item_produced
    else
      item = Item.source(region.world).trade_good(self.trade_good_type).first
    end
    region.max_resource_building_level(item)
  end

  def building_function
    @building_function ||= if trade_hall?
      "Allows trade and recruitment of #{self.recruitment_type.pluralize}"
    elsif orbital_dock?
      "Allows docking at estate without thrusters"
    elsif shuttle_capacity > 0
      "Allows transfer of #{shuttle_capacity} mass of items / level"
    elsif ship_hulls_assembled > 0
      "Build starships (#{ship_hulls_assembled} hulls / level)"
    elsif production_capacity > 0
      "Make items (#{production_capacity} mass / level)"
    elsif recruitment? && self.item_produced
      "Recruit #{self.item_produced.name.pluralize}"
    elsif recruitment? && self.recruitment_type
      "Recruit #{self.recruitment_type.pluralize}"
    elsif resource_gathering? && trade_good?
      "Gather #{self.trade_good_type.pluralize}"
    elsif resource_gathering? && self.item_produced
      "Produce #{self.item_produced.name.pluralize}"
    elsif can_join_clergy?
      "Ecclesiastical (Allows Tithing)"
    elsif tithe_modifier > 0
      "Ecclesiastical (Tithes Modifier: #{tithe_modifier})"
    elsif hospital?
      "Improve chance of recovery from illness, injury or wounds"
    else
      "Administration"
    end
  end

  def to_s
    self.category
  end
end
