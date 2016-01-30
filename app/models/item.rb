class Item < ActiveRecord::Base#
  attr_accessible :name, :category, :mass, :rich_yield, :normal_yield, :poor_yield, :description, :project_required, :trade_good_type, :source_world, :worker_type, :air_supremacy, :strategic_to_hit, :strategic_damage, :tactical_to_hit, :tactical_damage, :hit_points, :ground_armour_save, :movement, :transport_capacity, :one_use, :immobile, :weapon_speed, :torpedo_launcher, :missile_launcher, :drone_launcher, :accuracy, :damage, :shot_down, :internal_damage, :lifeform_damage, :reduce_speed, :building_bombardment, :item_bombardment, :armour_slots, :command_slots, :mission_slots, :engine_slots, :utility_slots, :primary_slots, :spinal_slots, :hull_points, :ship_armour_light, :ship_armour_normal, :ship_armour_heavy, :ship_shield_low, :ship_shield_medium, :ship_shield_high, :sensor_power, :jammer_power_full, :jammer_power_partial, :accuracy_modifier, :cloak, :escape_pod, :bridge, :nano_repair, :orbital_trade, :ammo_capacity, :worker_capacity, :troop_capacity, :ore_capacity, :cargo_capacity, :impulse_speed, :impulse_modifier, :thrust_speed, :dodge_speed

  self.per_page = 10  

  MAX_QUANTITY = 10000000

  ORE = "Ore"
  TRADE_GOOD = "Trade Good"
  WORKER = "Worker"
  TROOP = "Troop"
  MODULE = "Building Module"
  INTERNAL = "Building Internal"
  TANK = "Tank"
  AIRCRAFT = "Aircraft"
  ORDINANCE = "Ordinance"
  TRANSPORT = "Transport"
  HULL = "Ship Hull"
  ARMOUR = "Ship Armour"
  COMMAND = "Command Section"
  MISSION = "Mission Section"
  ENGINE = "Engine Section"
  UTILITY = "Utility Section"
  LAUNCHER = "Launcher"
  TORPEDO = "Torpedo"
  MISSILE = "Missile"
  DRONE = "Drone"
  BEAM_WEAPON = "Beam Weapon"
  KINETIC_WEAPON = "Kinetic Weapon"
  SPINAL_MOUNT = "Spinal Mount Weapon"
  ARTEFACT = "Artefact"

  ITEM_TYPES = [ORE, TRADE_GOOD, WORKER, TROOP,
                MODULE, INTERNAL,
                TANK, AIRCRAFT, ORDINANCE, TRANSPORT,
                HULL, ARMOUR, COMMAND, MISSION, ENGINE, UTILITY,
                LAUNCHER, BEAM_WEAPON, KINETIC_WEAPON, SPINAL_MOUNT,
                TORPEDO, MISSILE, DRONE,ARTEFACT]
  
  CARGO = [ORE, TRADE_GOOD, MODULE, INTERNAL, TANK, AIRCRAFT, ORDINANCE, TRANSPORT, HULL, ARMOUR, COMMAND, MISSION, ENGINE, UTILITY, LAUNCHER, BEAM_WEAPON, KINETIC_WEAPON, SPINAL_MOUNT, DRONE, ARTEFACT]
  CARGO_AND_TROOPS = CARGO + [TROOP]
  LIFEFORMS = [WORKER,TROOP]
  AMMO = [TORPEDO, MISSILE]
  NAVAL = [HULL, ARMOUR, COMMAND, MISSION, ENGINE, UTILITY,
                LAUNCHER, BEAM_WEAPON, KINETIC_WEAPON, SPINAL_MOUNT]
  SHIP_SECTIONS = [ARMOUR, COMMAND, MISSION, ENGINE, UTILITY,
                LAUNCHER, BEAM_WEAPON, KINETIC_WEAPON, SPINAL_MOUNT]
  MILITARY = [TROOP, TANK, AIRCRAFT, ORDINANCE, TRANSPORT]
  SHIP_PRIMARY_WEAPONS = [LAUNCHER, BEAM_WEAPON, KINETIC_WEAPON]

  PRODUCABLE = [MODULE, INTERNAL,
                TANK, AIRCRAFT, ORDINANCE, TRANSPORT,
                HULL, ARMOUR, COMMAND, MISSION, ENGINE, UTILITY,
                LAUNCHER, BEAM_WEAPON, KINETIC_WEAPON, SPINAL_MOUNT,
                TORPEDO, MISSILE, DRONE]
  WEDDING = [TRADE_GOOD]                
  
  NONE = ""
  FAST = "Fast"
  MEDIUM = "Medium"
  SLOW = "Slow"
  
  WEAPON_SPEEDS = [FAST,MEDIUM,SLOW,NONE]

  MOVEMENT_GROUND = "Ground"
  MOVEMENT_AIR = "Air"
  MOVEMENT_ORBIT = "Orbit"

  MOVEMENT_TYPES = [NONE,MOVEMENT_GROUND, MOVEMENT_AIR, MOVEMENT_ORBIT]

  SLAVE_WORKER = "Slave"
  FREEMEN_WORKER = "Freemen"
  ARTISAN_WORKER = "Artisan"

  WORKER_TYPES = [NONE,SLAVE_WORKER,FREEMEN_WORKER,ARTISAN_WORKER]

  FOOD_GRAIN = "Grain"
  FOOD_MEAT = "Meat"
  FOOD_FISH = "Fish"

  FOOD_TYPES = [FOOD_GRAIN, FOOD_MEAT, FOOD_FISH]

  CLOTHING_FUR = "Fur"
  CLOTHING_CLOTH = "Cloth"
  CLOTHING_SILK = "Silk"

  CLOTHING_TYPES = [CLOTHING_FUR, CLOTHING_CLOTH, CLOTHING_SILK]

  DRINK_MEAD = "Mead"
  DRINK_BEER = "Beer"
  DRINK_WINE = "Wine"

  DRINK_TYPES = [DRINK_MEAD, DRINK_BEER, DRINK_WINE]
  
  TRADE_GOOD_TYPES = [NONE] + FOOD_TYPES + CLOTHING_TYPES + DRINK_TYPES

  SECTION_TYPES = [NONE, ARMOUR, COMMAND, MISSION, ENGINE, UTILITY, SPINAL_MOUNT] + SHIP_PRIMARY_WEAPONS

  VALID_PRIJECT_TYPES = ([NONE] + WorldProject::PROJECT_TYPES)

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :mass, :only_integer => true
  validates_inclusion_of :category, :in => ITEM_TYPES

  scope :named, lambda {|n|
    {:conditions => {:name => n}, :order => 'name ASC'}
  }

  scope :category, lambda {|c|
    {:conditions => {:category => c}, :order => 'name ASC'}
  }

  scope :not_category, lambda {|c|
    {:conditions => ["category <> ?",c], :order => 'name ASC'}
  }

  scope :categories, lambda {|categories|
    {:conditions => ["category IN (?)",categories], :order => 'name ASC'}
  }

  scope :not_categories, lambda {|categories|
    {:conditions => ["category NOT IN (?)",categories], :order => 'name ASC'}
  }

  validates_numericality_of :rich_yield, :only_integer => true
  validates_numericality_of :normal_yield, :only_integer => true
  validates_numericality_of :poor_yield, :only_integer => true

  def yield_value(yield_category)
    case yield_category
    when Resource::RICH
      self.rich_yield
    when Resource::NORMAL
      self.normal_yield
    when Resource::POOR
      self.poor_yield
    else
      0
    end
  end

  # torpedo_launcher
  # missile_launcher
  # drone_launcher
  
  chance :air_supremacy
  chance :strategic_to_hit
  dice :strategic_damage
  chance :tactical_to_hit
  dice :tactical_damage

  validates_numericality_of :hit_points, :only_integer => true
  
  chance :ground_armour_save

  validates_inclusion_of :weapon_speed, :in => WEAPON_SPEEDS
  chance :accuracy
  dice :damage
  chance :shot_down
  chance :building_bombardment
  dice :item_bombardment

  validates_numericality_of :internal_damage, :only_integer => true
  validates_numericality_of :lifeform_damage, :only_integer => true
  
  # reduce_speed
  validates_numericality_of :accuracy_modifier, :only_integer => true

  validates_numericality_of :armour_slots
  validates_numericality_of :command_slots
  validates_numericality_of :mission_slots
  validates_numericality_of :engine_slots
  validates_numericality_of :utility_slots
  validates_numericality_of :primary_slots
  validates_numericality_of :spinal_slots
  validates_numericality_of :hull_points, :only_integer => true

  chance :ship_armour_light
  chance :ship_armour_normal
  chance :ship_armour_heavy

  chance :ship_shield_low
  chance :ship_shield_medium
  chance :ship_shield_high

  chance :sensor_power
  chance :jammer_power_full
  chance :jammer_power_partial

  # bridge
  # cloak
  # escape_pod
  # nano_repair

  validates_inclusion_of :movement, :in => MOVEMENT_TYPES
  validates_numericality_of :transport_capacity, :only_integer => true

  # one_use
  validates_numericality_of :ammo_capacity, :only_integer => true
  validates_numericality_of :worker_capacity, :only_integer => true
  validates_numericality_of :troop_capacity, :only_integer => true
  validates_numericality_of :ore_capacity, :only_integer => true
  validates_numericality_of :cargo_capacity, :only_integer => true

  validates_numericality_of :impulse_speed
  validates_numericality_of :impulse_modifier
  validates_numericality_of :thrust_speed
  validates_numericality_of :dodge_speed

  validates_inclusion_of :worker_type, :in => WORKER_TYPES

  scope :worker, lambda {|category|
    {:conditions => {:worker_type => category}}
  }

  validates_inclusion_of :trade_good_type, :in => TRADE_GOOD_TYPES

  scope :trade_good, lambda {|category|
    {:conditions => {:trade_good_type => category}}
  }

  scope :food, :conditions => ["trade_good_type IN (?)", FOOD_TYPES]
  scope :drink, :conditions => ["trade_good_type IN (?)", DRINK_TYPES]
  scope :clothing, :conditions => ["trade_good_type IN (?)", CLOTHING_TYPES]

  belongs_to :source_world, :class_name => 'World'

  scope :source, lambda {|world|
    {:conditions => {:source_world_id => world.id}}
  }

  validates_inclusion_of :project_required, :in => Item::VALID_PRIJECT_TYPES

  scope :project, lambda {|project|
    {:conditions => {:project_required => project.category}}
  }

  include RawMaterials

  has_many :item_bundles, :dependent => :destroy
  has_many :market_items, :dependent => :destroy

  # orbital_trade

  # immobile
  scope :mobile, :conditions => {:immobile => false}

  def self.create_item!(name,mass,category)
    create!(:name => name, :mass => mass, :category => category)
  end

  def self.create_artefact!(name, mass=1)
    create!(:name => name, :mass => mass, :category => ARTEFACT)
  end

  def self.create_ore!(name,rich_yield,normal_yield,poor_yield)
    create!(:name => name, :category => ORE, :mass => 1, :rich_yield => rich_yield, :normal_yield => normal_yield, :poor_yield => poor_yield)
  end

  def self.create_trade_good!(trade_good_type, world, name="#{world.name} #{trade_good_type}")
    rich_yield = case trade_good_type
    when FOOD_GRAIN
      "5d10+145".roll
    when FOOD_MEAT
      "5d10+95".roll
    when FOOD_FISH
      "5d10+45".roll
    when CLOTHING_FUR
      "5d6+45".roll
    when CLOTHING_CLOTH
      "5d6+45".roll
    when CLOTHING_SILK
      "5d6".roll
    when DRINK_MEAD
      "5d8+95".roll
    when DRINK_BEER
      "5d8+145".roll
    when DRINK_WINE
      "5d8+45".roll
    end
    normal_yield = case trade_good_type
    when FOOD_GRAIN
      "5d10+95".roll
    when FOOD_MEAT
      "5d10+45".roll
    when FOOD_FISH
      "5d10".roll
    when CLOTHING_FUR
      "5d6".roll
    when CLOTHING_CLOTH
      "5d6".roll
    when CLOTHING_SILK
      "5d6-5".roll
    when DRINK_MEAD
      "5d8+45".roll
    when DRINK_BEER
      "5d8+95".roll
    when DRINK_WINE
      "5d8".roll
    end
    poor_yield = case trade_good_type
    when FOOD_GRAIN
      "5d10+45".roll
    when FOOD_MEAT
      "5d10".roll
    when FOOD_FISH
      0
    when CLOTHING_FUR
      0
    when CLOTHING_CLOTH
      "5d6-5".roll
    when CLOTHING_SILK
      0
    when DRINK_MEAD
      "5d8-5".roll
    when DRINK_BEER
      "5d8+45".roll
    when DRINK_WINE
      "5d8-5".roll
    end
    create!(:name => name, :category => TRADE_GOOD, :trade_good_type => trade_good_type, :mass => 1, :source_world => world, :rich_yield => rich_yield, :normal_yield => normal_yield, :poor_yield => poor_yield)
  end

  def self.create_worker!(worker_type, world, name="#{world.name} #{worker_type}")
    create!(:name => name, :category => WORKER, :worker_type => worker_type, :mass => 1, :source_world => world)
  end

  def self.create_troop!(name, hit_chance, damage_dice, armour_chance=nil, movement=MOVEMENT_GROUND)
    create!(:name => name, :category => TROOP, :mass => 1, 
      :tactical_to_hit => hit_chance, :tactical_damage => damage_dice, :hit_points => 1,
      :ground_armour_save => armour_chance, :movement => movement)
  end

  def self.create_module!(name, mass, raw_materials)
    i = create!(:name => name, :category => MODULE, :mass => mass)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_tank!(name, mass, raw_materials, hit_chance, damage_dice, hp, armour_chance, project_required=NONE, movement=MOVEMENT_GROUND)
    i = create!(:name => name, :category => TANK, :mass => mass,
      :tactical_to_hit => hit_chance, :tactical_damage => damage_dice, :hit_points => hp,
      :ground_armour_save => armour_chance, :movement => movement, :project_required => project_required)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_aircraft!(name, mass, raw_materials, air_supremacy, strategic_hit_chance, strategic_damage_dice, project_required, tactical_hit_chance=nil,tactical_damage_dice=nil)
    i = create!(:name => name, :category => AIRCRAFT, :mass => mass, :air_supremacy => air_supremacy,
      :hit_points => 1, :movement => MOVEMENT_AIR, :project_required => project_required,
      :tactical_to_hit => tactical_hit_chance, :tactical_damage => tactical_damage_dice,
      :strategic_to_hit => strategic_hit_chance, :strategic_damage => strategic_damage_dice
    )
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_ordinance!(name, mass, raw_materials, hit_chance, damage_dice, hp, project_required, tactical_hit_chance=nil,tactical_damage_dice=nil, armour_chance=nil, immobile=false)
    i = create!(:name => name, :category => ORDINANCE, :mass => mass,
      :strategic_to_hit => hit_chance, :strategic_damage => damage_dice, :hit_points => hp, :immobile => immobile,
      :tactical_to_hit => tactical_hit_chance, :tactical_damage => tactical_damage_dice,
      :ground_armour_save => armour_chance, :movement => immobile ? '' : MOVEMENT_GROUND, :project_required => project_required)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_transport!(name,mass,raw_materials,transport_capacity,one_use=false,hp=(mass/10))
    i = create!(:name => name, :category => TRANSPORT, :mass => mass,
      :hit_points => hp, :one_use => one_use, :transport_capacity => transport_capacity,
      :movement => MOVEMENT_ORBIT, :project_required => WorldProject::ORBITAL_WARFARE)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_hull!(name,mass,raw_materials,hp,armour_slots,command_slots,mission_slots,engine_slots,utility_slots,primary_slots,spinal_slots,project_required=NONE)
    i = create!(:name => name, :category => HULL, :mass => mass, :hull_points => hp, :project_required => project_required,
      :armour_slots => armour_slots, :command_slots => command_slots, :mission_slots => mission_slots,
      :engine_slots => engine_slots, :utility_slots => utility_slots,
      :primary_slots => primary_slots, :spinal_slots => spinal_slots
    )
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_armour!(name,mass,raw_materials,light,normal,heavy,project_required=NONE)
    i = create!(:name => name, :category => ARMOUR, :mass => mass, :project_required => project_required,
      :ship_armour_light => light, :ship_armour_normal => normal, :ship_armour_heavy => heavy)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_command!(name,mass,raw_materials,project_required=NONE)
    i = create!(:name => name, :category => COMMAND, :mass => mass, :project_required => project_required)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_mission!(name,mass,raw_materials,project_required=NONE)
    i = create!(:name => name, :category => MISSION, :mass => mass, :project_required => project_required)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_utility!(name,mass,raw_materials,project_required=NONE)
    i = create!(:name => name, :category => UTILITY, :mass => mass, :project_required => project_required)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_engine!(name,mass,raw_materials,project_required=NONE)
    i = create!(:name => name, :category => ENGINE, :mass => mass, :project_required => project_required)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_launcher!(name,mass,raw_materials,ammo_type,project_required=NONE)
    i = create!(:name => name, :category => LAUNCHER, :mass => mass, :project_required => project_required, :accuracy => "5 on 1d10")
    case ammo_type
    when TORPEDO
      i.update_attributes!(:torpedo_launcher => true, :weapon_speed => SLOW)
    when MISSILE
      i.update_attributes!(:missile_launcher => true, :weapon_speed => MEDIUM)
    when DRONE
      i.update_attributes!(:drone_launcher => true, :weapon_speed => MEDIUM)
    end
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_ammo!(name,mass,raw_materials,ammo_type,damage,project_required=NONE,shot_down=nil)
    i = create!(:name => name, :category => ammo_type, :mass => mass, :project_required => project_required, :damage => damage, :shot_down => shot_down)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_beam_weapon!(name,mass,raw_materials,damage,project_required=NONE)
    i = create!(:name => name, :category => BEAM_WEAPON, :mass => mass, :project_required => project_required,
      :accuracy => "4 on 1d10".chance, :damage => damage, :weapon_speed => FAST)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_kinetic_weapon!(name,mass,raw_materials,damage,weapon_speed,building_bombardment,item_bombardment,project_required)
    i = create!(:name => name, :category => KINETIC_WEAPON, :mass => mass, :project_required => project_required, 
      :accuracy => "7 on 1d10".chance, :damage => damage, :weapon_speed => weapon_speed,
      :building_bombardment => building_bombardment, :item_bombardment => item_bombardment)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def self.create_spinal_mount!(name,mass,raw_materials,damage,weapon_speed,project_required)
    i = create!(:name => name, :category => SPINAL_MOUNT, :mass => mass, :project_required => project_required,
      :accuracy => "6 on 1d10", :damage => damage, :weapon_speed => weapon_speed)
    i.add_all_raw_materials!(raw_materials)
    i
  end

  def ore?
    self.category == ORE
  end

  def trade_good?
    self.category == TRADE_GOOD
  end

  def module?
    self.category == MODULE
  end

  def worker?
    self.category == WORKER
  end

  def troop?
    self.category == TROOP
  end

  def lifeform?
    LIFEFORMS.include?(self.category)
  end

  def cargo?
    CARGO.include?(self.category)
  end

  def ammo?
    AMMO.include?(self.category)
  end

  def drone?
    self.category == DRONE
  end

  def military?
    MILITARY.include?(self.category)
  end

  def naval?
    NAVAL.include?(self.category)
  end

  def section?
    SHIP_SECTIONS.include?(self.category)
  end

  def hull?
    self.category == HULL
  end

  def light_hull?
    self.name == "Light Hull"
  end

  def standard_hull?
    self.name == "Standard Hull"
  end

  def reinforced_hull?
    self.name == "Reinforced Hull"
  end

  def armour?
    self.category == ARMOUR
  end

  def shield?
    self.ship_shield_low || self.ship_shield_medium || ship_shield_high
  end

  def primary_weapon?
    SHIP_PRIMARY_WEAPONS.include?(self.category)
  end

  def launcher?
    self.category == LAUNCHER
  end

  def kinetic?
    self.category == KINETIC_WEAPON
  end

  def spinal_mount?
    self.category == SPINAL_MOUNT
  end

  def space_weapon?
    primary_weapon? || spinal_mount?
  end

  def bombardment_weapon?
    self.building_bombardment || self.item_bombardment
  end

  def stealth_plate?
    self.name == "Stealth Plate"
  end

  def sensor?
    self.sensor_power && self.sensor_power != 0
  end

  def jammer?
    self.jammer_power_full && self.jammer_power_full != 0
  end

  def restricted?
    !self.project_required.blank?
  end

  def bombarded_modifier
    return 1 if trade_good?
    return -2 if military?
    return -1 if naval?
    return -3 if lifeform?
    0
  end

  def slave?
    self.worker_type == SLAVE_WORKER
  end

  def freemen?
    self.worker_type == FREEMEN_WORKER
  end

  def artisan?
    self.worker_type == ARTISAN_WORKER
  end

  def ground_movement_only?
    self.movement == MOVEMENT_GROUND
  end

  def shield_piercing
    return case self.category
    when BEAM_WEAPON
      -1
    when LAUNCHER
      0
    when KINETIC_WEAPON
      2
    when SPINAL_MOUNT
      3
    else
      0
    end
  end

  def valid_ammo
    return Item.category(TORPEDO) if self.torpedo_launcher?
    return Item.category(MISSILE) if self.missile_launcher?
    return Item.category(DRONE) if self.drone_launcher?
    []
  end

  def catering?
    self.category == TRADE_GOOD && (FOOD_TYPES.include?(self.trade_good_type) || DRINK_TYPES.include?(self.trade_good_type))
  end

  def gift?
    self.category == TRADE_GOOD && CLOTHING_TYPES.include?(self.trade_good_type)
  end
end


