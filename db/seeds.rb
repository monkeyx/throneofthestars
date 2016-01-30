include Log
include Names
include AncientHouse

Game.transaction do
  Log.info "SEED", "Cleaning up"
  Game.delete_all
  Item.delete_all
  BuildingType.delete_all
  StarshipType.delete_all
  NobleHouse.delete_all
  Character.delete_all
  Estate.delete_all
  Starship.delete_all
  Army.delete_all
  World.delete_all
  Region.delete_all
  Resource.delete_all

  Log.info "SEED", "Game #{Game.current.id} - #{Game.current_date.pt}"
  
  Log.info "SEED", "Items"
  metals = Item.create_ore!('Metals',150,75,25)
  rare_elements = Item.create_ore!('Rare Elements',10,5,2)
  carbonite = Item.create_ore!('Carbonite',150,75,25)
  fissile = Item.create_ore!('Fissile',10,5,2)

  soldier = Item.create_troop!('Soldier', "7 on 1d10".chance, "1d4".dice)
  marine = Item.create_troop!('Marine', "6 on 1d10".chance, "1d4".dice)
  vanguard = Item.create_troop!('Vanguard', "4 on 1d10".chance, "1d6+1".dice, "7 on 1d10".chance, Item::MOVEMENT_ORBIT)

  sm = Item.create_module!('Structural Module', 10,{metals => 4, carbonite => 6})
  hm = Item.create_module!('Habitation Module', 10,{metals => 2, carbonite => 8})
  mm = Item.create_module!('Military Module', 10,{metals => 4, carbonite => 4, rare_elements => 2})
  it = Item.create_module!('Industrial Tools', 2,{metals => 1, rare_elements => 1})
  at = Item.create_module!('Agricultural Tools', 2,{metals => 1, carbonite => 1})
  cg = Item.create_module!('Consumer Goods', 2,{carbonite => 1, rare_elements => 1})

  light_tank = Item.create_tank!('Light Tank',20,{metals => 15, carbonite => 5},"6 on 1d10".chance, "1d6".dice, 2, "10 on 1d10".chance)
  battle_tank = Item.create_tank!('Battle Tank',100,{metals => 70, carbonite => 20, rare_elements => 5, fissile => 5},"5 on 1d10".chance, "2d6".dice, 4, "9 on 1d10".chance, WorldProject::MECHANIZED_INFANTRY)
  assault_tank = Item.create_tank!('Assault Tank',60,{metals => 40, carbonite => 10, rare_elements => 5, fissile => 5},"4 on 1d10".chance, "3d6".dice, 2, "8 on 1d10".chance, WorldProject::SPECIAL_FORCES, Item::MOVEMENT_ORBIT)

  gunship = Item.create_aircraft!("Gunship", 10, {metals => 8, carbonite => 2}, nil, nil, nil, WorldProject::COMBINED_ARMS, "5 on 1d10".chance, "1d8".dice)
  fighter = Item.create_aircraft!("Fighter", 20, {metals => 10, carbonite => 5, rare_elements => 5}, "4 on 1d10".chance, "5 on 1d10".chance, "1d4".dice, WorldProject::AIR_WARFARE)
  bomber = Item.create_aircraft!("Bomber", 40, {metals => 20, carbonite => 10, rare_elements => 5, fissile => 5}, "7 on 1d10".chance, "4 on 1d10".chance, "2d6".dice, WorldProject::AIR_WARFARE)

  bunker = Item.create_ordinance!("Defense Bunker", 250, {metals => 125, carbonite => 125}, nil,nil, 8, '', "7 on 1d10".chance, "2d6".dice, "7 on 1d10".chance, true)
  rocket = Item.create_ordinance!("Rocket Artillery", 50, {metals => 30, carbonite => 10, rare_elements => 5, fissile => 5}, "6 on 1d10".chance, "2d8".dice, 1, WorldProject::STRATEGIC_WARFARE)
  orbital_platform = Item.create_ordinance!("Orbital Weapons Platform", 100, {metals => 50, carbonite => 40, rare_elements => 5, fissile => 5}, "3 on 1d10".chance, "3d6".dice, 1, WorldProject::ORBITAL_WARFARE,nil,nil,nil,true)

  shuttle = Item.create_transport!("Shuttle",40,{metals => 20, carbonite => 15, rare_elements => 4, fissile => 1},20)
  heavy_shuttle = Item.create_transport!("Heavy Shuttle",150,{metals => 100, carbonite => 20, rare_elements => 15, fissile => 5},100)

  # create_hull!(name,mass,raw_materials,hp,armour_slots,command_slots,mission_slots,engine_slots,utility_slots,primary_slots,spinal_slots)
  standard_hull = Item.create_hull!("Standard Hull",200,{metals => 100, carbonite => 80, rare_elements => 20},2,
      1, # armour_slots,
      3,# command_slots,
      0.1,# mission_slots,
      0.1,# engine_slots,
      0.02,# utility_slots,
      0.05,# primary_slots,
      0)# spinal_slots)
  reinforced_hull = Item.create_hull!("Reinforced Hull",400,{metals => 280, carbonite => 80, rare_elements => 40},4,
    2,#armour_slots,
    4,#command_slots,
    0.05,#mission_slots,
    0.1,#engine_slots,
    0.01,#utility_slots,
    0.1,#primary_slots,
    0.01,#spinal_slots,
    WorldProject::SCIENCE_ACADEMY)
  light_hull = Item.create_hull!("Light Hull",100,{metals => 20, carbonite => 60, rare_elements => 20},1,
    0.2,# armour_slots,
    2,# command_slots,
    0.2,# mission_slots,
    0.04,# engine_slots,
    0,# utility_slots,
    0,# primary_slots,
    0,# spinal_slots,
    WorldProject::ENGINEERING_ACADEMY)

  # create_armour!(name,mass,raw_materials,light,normal,heavy,project_required=NONE)
  armour_plate = Item.create_armour!("Armour Plate",100,{metals => 100},"10 on 1d10".chance,"9 on 1d10".chance,"8 on 1d10".chance)
  ablative_mesh = Item.create_armour!("Ablative Mesh",100,{metals => 20, carbonite => 50, rare_elements => 30},"9 on 1d10".chance,"8 on 1d10".chance,"7 on 1d10".chance, WorldProject::SPIRIT_ATOM)
  stealth_plate = Item.create_armour!("Stealth Plate",50,{carbonite => 25, rare_elements => 25},nil,nil,nil, WorldProject::FAITH_SHADOW)
  stealth_plate.update_attributes!(:jammer_power_full => "2 on 1d6".chance,:jammer_power_partial => "4 on 1d6".chance)

  # create_command!(name,mass,raw_materials,project_required=NONE)
  bridge = Item.create_command!("Bridge",2000,{carbonite => 1800, rare_elements => 200})
  bridge.update_attributes!(:bridge => true)
  escape_pods = Item.create_command!("Escape Pods",1000,{metals => 500, carbonite => 400, rare_elements => 80, fissile => 20})
  escape_pods.update_attributes!(:escape_pod => true)
  sensor = Item.create_command!("Sensor",1000,{metals => 500, rare_elements => 500})
  sensor.update_attributes!(:sensor_power => "6 on 1d10".chance)
  battle_computer = Item.create_command!("Battle Computer",1000,{carbonite => 500, rare_elements => 500}, WorldProject::SPIRIT_MACHINE)
  battle_computer.update_attributes!(:accuracy_modifier => 1)
  ecm = Item.create_command!("ECM",1000,{carbonite => 200, rare_elements => 800}, WorldProject::SPIRIT_MACHINE)
  ecm.update_attributes!(:jammer_power_full => "3 on 1d6".chance,:jammer_power_partial => "3 on 1d6".chance)

  # create_mission!(name,mass,raw_materials,project_required=NONE)
  magazine = Item.create_mission!("Magazine",2000,{metals => 1000, carbonite => 900, rare_elements => 100})
  magazine.update_attributes!(:ammo_capacity => 200)
  cargo_bay = Item.create_mission!("Cargo Bay",2500,{metals => 2000, carbonite => 500})
  cargo_bay.update_attributes!(:cargo_capacity => 1500)
  ore_bay = Item.create_mission!("Ore Bay",2500,{metals => 2400, carbonite => 100})
  ore_bay.update_attributes!(:ore_capacity => 2500)
  quarters = Item.create_mission!("Quarters",2500,{metals => 1000, carbonite => 1500})
  quarters.update_attributes!(:worker_capacity => 200)
  bunks = Item.create_mission!("Bunks",5000,{metals => 2500, carbonite => 2500})
  bunks.update_attributes!(:troop_capacity => 100)
  shields = Item.create_mission!("Shield Generator",5000,{metals => 3000, rare_elements => 1000, fissile => 1000}, WorldProject::DEVOTION_ENERGY)
  shields.update_attributes!(:ship_shield_low => "9 on 1d10".chance, :ship_shield_medium => "8 on 1d10".chance, :ship_shield_high => "7 on 1d10".chance)

  # create_utility!(name,mass,raw_materials,project_required=NONE)
  cloaking_device = Item.create_utility!("Cloaking Device",5000,{metals => 1000, carbonite => 1000, rare_elements => 1500, fissile => 1500},WorldProject::FAITH_SHADOW)
  cloaking_device.update_attributes!(:cloak => true)
  nav_computer = Item.create_utility!("Navigation Computer",5000,{carbonite => 1000, rare_elements => 4000},WorldProject::SPIRIT_MACHINE)
  nav_computer.update_attributes!(:impulse_modifier => -0.25)
  nano_repair = Item.create_utility!("Nano Repair Unit",5000,{carbonite => 4000, rare_elements => 1000},WorldProject::SPIRIT_LIVING)
  nano_repair.update_attributes!(:nano_repair => true)

  # create_engine!(name,mass,raw_materials,project_required=NONE)
  impulse_drive = Item.create_engine!("Impulse Drive",5000,{metals => 3000, rare_elements => 1000, fissile => 1000})
  impulse_drive.update_attributes!(:impulse_speed => 1.0)
  thrusters = Item.create_engine!("Thrusters",500,{metals => 300, rare_elements => 100, fissile => 100})
  thrusters.update_attributes!(:thrust_speed => 20)
  gravity_anchor = Item.create_engine!("Gravity Anchor",10000,{metals => 3000, carbonite => 4000, rare_elements => 2500, fissile => 500})
  gravity_anchor.update_attributes!(:orbital_trade => true)
  boosters = Item.create_engine!("Boosters",200,{metals => 50, carbonite => 50, rare_elements => 50, fissile => 50},WorldProject::SPIRIT_ATOM)
  boosters.update_attributes!(:dodge_speed => 24)

  # create_launcher!(name,mass,raw_materials,ammo_type,accuracy,project_required=NONE)
  torpedo_launcher = Item.create_launcher!("Torpedo Launcher",1000,{metals => 1000},Item::TORPEDO)
  missile_launcher = Item.create_launcher!("Missile Launcher",1000,{metals => 1000},Item::MISSILE)
  drone_bay = Item.create_launcher!("Drone Bay",5000,{metals => 2400, carbonite => 2600},Item::DRONE)
  
  # create_ammo!(name,mass,raw_materials,ammo_type,damage,project_required=NONE,shot_down=nil)
  proton_torpedo = Item.create_ammo!("Proton Torpedo",5,{metals => 3, fissile =>2},Item::TORPEDO,"2d12".dice)
  neutron_torpedo = Item.create_ammo!("Neutron Torpedo",5,{metals => 3, rare_elements => 1, fissile =>1},Item::TORPEDO,"4d12+6".dice,WorldProject::SPIRIT_ATOM)
  phased_torpedo = Item.create_ammo!("Phased Torpedo",5,{metals => 3, rare_elements => 2},Item::TORPEDO,"8d12+12".dice,WorldProject::FAITH_QUANTUM)

  nuclear_missile = Item.create_ammo!("Nuclear Missile",2,{metals => 1, fissile => 1},Item::MISSILE,"2d10".dice)
  antimatter_missile = Item.create_ammo!("Antimatter Missile",2,{metals => 1, rare_elements => 1},Item::MISSILE,"4d10+5".dice,WorldProject::DEVOTION_MATTER)
  nanite_missile = Item.create_ammo!("Nanite Missile",2,{metals => 1, carbonite => 1},Item::MISSILE,"8d10+10".dice,WorldProject::SPIRIT_LIVING)

  interceptor = Item.create_ammo!("Interceptor",20,{metals => 15, carbonite => 4, rare_elements => 1},Item::DRONE,"1d6".dice,Item::NONE,"7 on 1d10".chance)
  disruptor = Item.create_ammo!("Disruptor",20,{metals => 14, carbonite => 4, rare_elements => 2},Item::DRONE,"2d6+3".dice,WorldProject::FAITH_LIGHT,"8 on 1d10".chance)
  guardian = Item.create_ammo!("Guardian",20,{metals => 12, carbonite => 4, rare_elements => 3, fissile => 1},Item::DRONE,"4d6+6".dice,WorldProject::DEVOTION_ENTROPY,"9 on 1d10".chance)

  # create_beam_weapon!(name,mass,raw_materials,accuracy,damage,project_required=NONE)
  phasers = Item.create_beam_weapon!("Phaser Beam",500,{metals => 400, rare_elements => 100},"2d4".dice)
  pulsars = Item.create_beam_weapon!("Pulsar Beam",500,{metals => 400, rare_elements => 100},"4d4+2".dice,WorldProject::FAITH_LIGHT)
  positron = Item.create_beam_weapon!("Positron Beam",500,{metals => 400, rare_elements => 100},"8d4+4".dice,WorldProject::FAITH_QUANTUM)

  # create_kinetic_weapon!(name,mass,raw_materials,damage,weapon_speed,building_bombardment,item_bombardment,project_required=NONE)
  mass_driver = Item.create_kinetic_weapon!("Mass Driver",1000,{metals => 800, carbonite => 200},"3d8".dice,Item::FAST,"8 on 1d10".chance,"1d6".dice,WorldProject::DEVOTION_ENERGY)
  rail_cannon = Item.create_kinetic_weapon!("Rail Cannon",2000,{metals => 1600, carbonite => 400},"6d8+8".dice,Item::MEDIUM,"6 on 1d10".chance,"1d8".dice,WorldProject::DEVOTION_MATTER)
  siege_mortar = Item.create_kinetic_weapon!("Siege Mortar",5000,{metals => 4000, carbonite => 1000},"12d8+16".dice,Item::SLOW,"4 on 1d10".chance,"1d12".dice,WorldProject::DEVOTION_ENTROPY)

  # create_spinal_mount!(name,mass,raw_materials,damage,weapon_speed,project_required)
  plasma_cannon = Item.create_spinal_mount!("Plasma Cannon",15000,{metals => 10000, rare_elements => 4000, fissile => 1000},"10d12".dice,Item::MEDIUM,WorldProject::DEVOTION_MATTER)
  plasma_cannon.update_attributes!(:internal_damage => 1)
  tractor_beam = Item.create_spinal_mount!("Tractor Beam",10000,{metals => 9000, rare_elements => 1000},nil,Item::MEDIUM,WorldProject::FAITH_QUANTUM)
  tractor_beam.update_attributes!(:reduce_speed => true)
  ion_cannon = Item.create_spinal_mount!("Ion Cannon",20000,{metals => 15000, rare_elements => 5000},"5d6".dice,Item::SLOW,WorldProject::DEVOTION_ENTROPY)
  ion_cannon.update_attributes!(:lifeform_damage => 25)

  Log.info "SEED", "Building Types"
  palace = BuildingType.create_civil!(BuildingType::PALACE, Item::FREEMEN_WORKER,100,{sm => 20, hm => 10, mm => 20})
  shuttle_port = BuildingType.create_civil!(BuildingType::SHUTTLE_PORT, Item::SLAVE_WORKER,100,{sm => 10, hm => 10, mm => 10, it => 100})
  orbital_dock = BuildingType.create_civil!(BuildingType::ORBITAL_DOCK, Item::SLAVE_WORKER,250,{sm => 20, hm => 25, mm => 25, it => 150})
  chapel = BuildingType.create_civil!(BuildingType::CHAPEL, Item::FREEMEN_WORKER,50,{sm => 5, hm => 5})
  church = BuildingType.create_civil!(BuildingType::CHURCH, Item::FREEMEN_WORKER,100,{sm => 10, hm => 10, cg => 25})
  cathedral = BuildingType.create_civil!(BuildingType::CATHEDRAL, Item::FREEMEN_WORKER,200,{sm => 20, hm => 20, cg => 50})

  mine = BuildingType.create_ore_gathering!(BuildingType::MINE, Item::SLAVE_WORKER,25,{sm => 5, hm => 2, it => 15},metals)
  forge = BuildingType.create_ore_gathering!(BuildingType::FORGE, Item::FREEMEN_WORKER,10,{sm => 5, hm => 1, it => 20},rare_elements)
  refinery = BuildingType.create_ore_gathering!(BuildingType::REFINERY, Item::FREEMEN_WORKER,25,{sm => 5, hm => 3, it => 10},carbonite)
  reactor = BuildingType.create_ore_gathering!(BuildingType::REACTOR, Item::FREEMEN_WORKER,10,{sm => 5, hm => 1, it => 20},fissile)

  farm = BuildingType.create_trade_good_gathering!(BuildingType::FARM, Item::SLAVE_WORKER,10,{sm => 5, hm => 1, at => 20},Item::FOOD_GRAIN)
  ranch = BuildingType.create_trade_good_gathering!(BuildingType::RANCH, Item::SLAVE_WORKER,10,{sm => 5, hm => 1, at => 20},Item::FOOD_MEAT)
  fishery = BuildingType.create_trade_good_gathering!(BuildingType::FISHERY, Item::FREEMEN_WORKER,10,{sm => 5, hm => 1, at => 20},Item::FOOD_FISH)

  hunting_lodge = BuildingType.create_trade_good_gathering!(BuildingType::HUNTING_LODGE, Item::FREEMEN_WORKER,10,{sm => 5, hm => 1, it => 10, at => 10},Item::CLOTHING_FUR)
  weavers = BuildingType.create_trade_good_gathering!(BuildingType::WEAVERS, Item::SLAVE_WORKER,25,{sm => 5, hm => 2, it => 15},Item::CLOTHING_CLOTH)
  silk_farm = BuildingType.create_trade_good_gathering!(BuildingType::SILK_FARM, Item::SLAVE_WORKER,25,{sm => 5, hm => 2, at => 15},Item::CLOTHING_SILK)

  meadery = BuildingType.create_trade_good_gathering!(BuildingType::MEADERY, Item::FREEMEN_WORKER,10,{sm => 5, hm => 1, it => 15, at => 5},Item::DRINK_MEAD)
  brewery = BuildingType.create_trade_good_gathering!(BuildingType::BREWERY, Item::FREEMEN_WORKER,10,{sm => 5, hm => 1, it => 10, at => 10},Item::DRINK_BEER)
  vineyard = BuildingType.create_trade_good_gathering!(BuildingType::VINEYARD, Item::SLAVE_WORKER,25,{sm => 5, hm => 2, it => 5, at => 10},Item::DRINK_WINE)

  trade_hall = BuildingType.create_worker_recruitment!(BuildingType::TRADE_HALL, Item::FREEMEN_WORKER,50,{sm => 10, hm => 5, mm => 5, cg => 25},Item::FREEMEN_WORKER,100)
  college = BuildingType.create_worker_recruitment!(BuildingType::COLLEGE, Item::FREEMEN_WORKER,250,{sm => 15, hm => 25, cg => 50},Item::ARTISAN_WORKER,50)

  barracks = BuildingType.create_troop_recruitment!(BuildingType::BARRACKS, Item::FREEMEN_WORKER,250,{mm => 10, sm => 10, hm => 25, cg => 25},soldier, 100)
  academy = BuildingType.create_troop_recruitment!(BuildingType::ACADEMY, Item::FREEMEN_WORKER,250,{mm => 10, sm => 10, hm => 25, cg => 25},marine, 50)

  workshop = BuildingType.create_civil!(BuildingType::WORKSHOP, Item::ARTISAN_WORKER,10,{sm => 5, hm => 10, it => 50})
  shipyard = BuildingType.create_civil!(BuildingType::SHIPYARD, Item::ARTISAN_WORKER,50,{sm => 20, hm => 50, mm => 10, it => 100})

  Log.info "SEED", "Starship Types"
  runner = StarshipType.define!("Runner", standard_hull, 20)
  far_trader = StarshipType.define!("Far Trader", standard_hull, 40)
  merchantman = StarshipType.define!("Merchantman", standard_hull, 80)
  galleas = StarshipType.define!("Galleas", light_hull, 100)
  cruise_liner = StarshipType.define!("Cruise Liner", light_hull, 150)
  behemoth = StarshipType.define!("Behemoth", light_hull, 200, WorldProject::GRAND_ACADEMY)
  tanker = StarshipType.define!("Tanker", light_hull, 400, WorldProject::GRAND_ACADEMY)
  gunboat = StarshipType.define!("Gunboat", reinforced_hull, 20)
  destroyer = StarshipType.define!("Destroyer", reinforced_hull, 40)
  light_frigate = StarshipType.define!("Light Frigate", reinforced_hull, 60)
  heavy_cruiser = StarshipType.define!("Heavy Cruiser", reinforced_hull, 80)
  battleship = StarshipType.define!("Battleship", reinforced_hull, 100, WorldProject::GRAND_ACADEMY)
  patrol_cruiser = StarshipType.define!("Patrol Cruiser", reinforced_hull, 150, WorldProject::GRAND_ACADEMY)
  dreadnought = StarshipType.define!("Dreadnought", reinforced_hull, 200, WorldProject::GRAND_ACADEMY)

  Log.info "SEED", "Starship Configurations"
  corvette = StarshipConfiguration.create_configuration!("Corvette",runner)
  corvette.add_sections!(armour_plate, 20)
  corvette.add_sections!(bridge, 1)
  corvette.add_sections!(sensor, 1)
  corvette.add_sections!(battle_computer, 1)
  corvette.add_sections!(bunks, 1)
  corvette.add_sections!(shields, 1)
  corvette.add_sections!(impulse_drive, 1)
  corvette.add_sections!(boosters, 1)
  corvette.add_sections!(phasers, 1)

  courier = StarshipConfiguration.create_configuration!("Courier", far_trader)
  courier.add_sections!(armour_plate, 20)
  courier.add_sections!(bridge, 1)
  courier.add_sections!(sensor, 1)
  courier.add_sections!(escape_pods, 1)
  courier.add_sections!(bunks, 1)
  courier.add_sections!(cargo_bay, 3)
  courier.add_sections!(impulse_drive, 1)
  courier.add_sections!(thrusters, 2)
  courier.add_sections!(gravity_anchor, 1)

  guildsman = StarshipConfiguration.create_configuration!("Guildsman", merchantman)
  guildsman.add_sections!(armour_plate,40)
  guildsman.add_sections!(bridge,1)
  guildsman.add_sections!(sensor,1)
  guildsman.add_sections!(ecm,1)
  guildsman.add_sections!(bunks,1)
  guildsman.add_sections!(shields,1)
  guildsman.add_sections!(quarters,2)
  guildsman.add_sections!(cargo_bay,3)
  guildsman.add_sections!(ore_bay,1)
  guildsman.add_sections!(nav_computer,1)
  guildsman.add_sections!(impulse_drive,1)
  guildsman.add_sections!(thrusters,4)
  guildsman.add_sections!(gravity_anchor,1)
  guildsman.add_sections!(phasers,2)

  ranger = StarshipConfiguration.create_configuration!("Ranger", gunboat)
  ranger.add_sections!(armour_plate,40)
  ranger.add_sections!(bridge,1)
  ranger.add_sections!(sensor,1)
  ranger.add_sections!(battle_computer,1)
  ranger.add_sections!(ecm,1)
  ranger.add_sections!(bunks,1)
  ranger.add_sections!(impulse_drive,1)
  ranger.add_sections!(boosters,1)
  ranger.add_sections!(phasers,2)

  imperial_transport = StarshipConfiguration.create_configuration!("Imperial Transport", galleas)
  imperial_transport.add_sections!(ablative_mesh,20)
  imperial_transport.add_sections!(bridge,1)
  imperial_transport.add_sections!(sensor,1)
  imperial_transport.add_sections!(impulse_drive,1)
  imperial_transport.add_sections!(gravity_anchor,1)
  imperial_transport.add_sections!(cargo_bay,15)
  imperial_transport.add_sections!(quarters,5)

  imperial_cruiser = StarshipConfiguration.create_configuration!("Imperial Cruiser", heavy_cruiser)
  imperial_cruiser.add_sections!(ablative_mesh,160)
  imperial_cruiser.add_sections!(bridge,1)
  imperial_cruiser.add_sections!(sensor,1)
  imperial_cruiser.add_sections!(battle_computer,1)
  imperial_cruiser.add_sections!(ecm,1)
  imperial_cruiser.add_sections!(bunks,2)
  imperial_cruiser.add_sections!(shields,1)
  imperial_cruiser.add_sections!(magazine,1)
  imperial_cruiser.add_sections!(impulse_drive,2)
  imperial_cruiser.add_sections!(boosters,5)
  imperial_cruiser.add_sections!(gravity_anchor,1)
  imperial_cruiser.add_sections!(missile_launcher,4)
  imperial_cruiser.add_sections!(positron,2)
  imperial_cruiser.add_sections!(torpedo_launcher,2)

  ship_of_the_line = StarshipConfiguration.create_configuration!("Ship of the Line", battleship)
  ship_of_the_line.add_sections!(ablative_mesh,200)
  ship_of_the_line.add_sections!(bridge,1)
  ship_of_the_line.add_sections!(sensor,1)
  ship_of_the_line.add_sections!(battle_computer,1)
  ship_of_the_line.add_sections!(escape_pods, 1)
  ship_of_the_line.add_sections!(bunks,3)
  ship_of_the_line.add_sections!(magazine,2)
  ship_of_the_line.add_sections!(impulse_drive,2)
  ship_of_the_line.add_sections!(boosters,7)
  ship_of_the_line.add_sections!(gravity_anchor,1)
  ship_of_the_line.add_sections!(missile_launcher,6)
  ship_of_the_line.add_sections!(positron,2)
  ship_of_the_line.add_sections!(drone_bay,2)
  ship_of_the_line.add_sections!(tractor_beam,1)

  Log.info "SEED", "Worlds"
  aquarium = World.create_world!("Aquarium", 9, 2)
  arium = World.create_world!("Arium", 18, 5)
  capricia = World.create_world!("Capricia", 3, 1)
  centraum = World.create_world!("Centraum", 12, 3)
  gemonia = World.create_world!("Gemonia", 7, 2)
  libram = World.create_world!("Libram", 16, 4)
  lyon = World.create_world!("Lyona", 5, 1)
  orion = World.create_world!("Orion", 15, 4)
  poisson = World.create_world!("Poisson", 20, 5)
  scorpia = World.create_world!("Scorpia", 8, 2)
  taura = World.create_world!("Taura", 14, 3)
  virgil = World.create_world!("Virgil", 24, 6)
  
  Log.info "SEED", "Regions"
  aquarium.add_region!("Atlantia",Region::NORTHERN,5000,[metals],[rare_elements],[Item::FOOD_GRAIN, Item::DRINK_WINE],[Item::CLOTHING_FUR,Item::CLOTHING_SILK])
  aquarium.add_region!("Ialandia",Region::NORTHERN,5000,[metals],[carbonite],[Item::FOOD_GRAIN, Item::DRINK_WINE],[Item::DRINK_BEER,Item::CLOTHING_SILK])
  aquarium.add_region!("Memooth",Region::NORTHERN,2500,[metals,carbonite],[],[Item::FOOD_MEAT],[Item::FOOD_MEAT,Item::FOOD_GRAIN,Item::CLOTHING_SILK])
  aquarium.add_region!("Achadia",Region::SOUTHERN,1250,[metals, fissile],[rare_elements],[Item::FOOD_FISH],[Item::CLOTHING_FUR,Item::CLOTHING_CLOTH, Item::FOOD_MEAT])
  aquarium.add_region!("Cycladic",Region::SOUTHERN,5000,[metals],[fissile],[Item::FOOD_FISH, Item::CLOTHING_SILK],[Item::CLOTHING_FUR,Item::DRINK_MEAD])

  arium.add_region!("Aethorn",Region::NORTHERN,1250,[metals,carbonite],[fissile],[Item::DRINK_MEAD],[Item::DRINK_WINE,Item::CLOTHING_SILK])
  arium.add_region!("Shikari",Region::NORTHERN,1250,[metals,carbonite,rare_elements],[],[],[Item::FOOD_GRAIN,Item::DRINK_BEER,Item::CLOTHING_SILK])
  arium.add_region!("Talon Peaks",Region::SOUTHERN,5000,[metals,carbonite,fissile],[],[],[Item::FOOD_GRAIN, Item::FOOD_MEAT,Item::FOOD_FISH])
  arium.add_region!("Ultrecht",Region::SOUTHERN,1000,[carbonite,rare_elements],[metals],[Item::CLOTHING_SILK],[Item::DRINK_WINE,Item::CLOTHING_FUR])
  arium.add_region!("Acrophylia",Region::SOUTHERN,2500,[carbonite,fissile],[],[Item::FOOD_MEAT],[Item::DRINK_MEAD,Item::DRINK_BEER,Item::FOOD_FISH])
  arium.add_region!("Desolace",Region::SOUTHERN,4000,[carbonite,fissile,rare_elements],[],[],[Item::FOOD_GRAIN,Item::FOOD_FISH,Item::DRINK_WINE])

  capricia.add_region!("Bloval",Region::NORTHERN,1500,[metals],[carbonite],[Item::DRINK_MEAD, Item::FOOD_GRAIN],[Item::FOOD_MEAT,Item::CLOTHING_FUR])
  capricia.add_region!("Dirkval",Region::NORTHERN,1000,[metals,fissile,rare_elements],[],[],[Item::DRINK_BEER, Item::DRINK_MEAD,Item::DRINK_WINE])
  capricia.add_region!("Solace",Region::NORTHERN,500,[],[],[Item::DRINK_BEER,Item::FOOD_GRAIN,Item::FOOD_FISH],[Item::CLOTHING_FUR,Item::DRINK_WINE,Item::CLOTHING_SILK])
  capricia.add_region!("Amazonia",Region::NORTHERN,5000,[carbonite],[metals, fissile],[Item::FOOD_MEAT, Item::CLOTHING_CLOTH],[Item::FOOD_GRAIN])
  capricia.add_region!("Hartval",Region::NORTHERN,5000,[metals],[],[Item::CLOTHING_FUR, Item::FOOD_MEAT],[Item::FOOD_GRAIN,Item::FOOD_FISH, Item::DRINK_MEAD])
  capricia.add_region!("Fallen Isle",Region::NORTHERN,2500,[fissile],[metals,carbonite,rare_elements],[Item::CLOTHING_SILK, Item::DRINK_WINE],[])

  centraum.add_region!("Tyrwood",Region::NORTHERN,2500,[metals, carbonite],[fissile,rare_elements],[Item::CLOTHING_FUR],[Item::CLOTHING_SILK])
  centraum.add_region!("Helwood",Region::NORTHERN,3000,[carbonite],[fissile,rare_elements],[Item::CLOTHING_FUR],[Item::CLOTHING_SILK])
  centraum.add_region!("Lokwood",Region::SOUTHERN,1500,[carbonite,fissile,rare_elements],[metals],[],[Item::DRINK_BEER,Item::DRINK_MEAD])
  centraum.add_region!("Odwood",Region::NORTHERN,5000,[carbonite,metals],[rare_elements,fissile],[Item::CLOTHING_FUR],[Item::CLOTHING_SILK])
  centraum.add_region!("Varwood",Region::NORTHERN,1500,[carbonite,metals],[rare_elements,fissile],[Item::CLOTHING_FUR],[Item::CLOTHING_SILK])
  centraum.add_region!("Freywood",Region::NORTHERN,2000,[carbonite],[rare_elements,fissile],[Item::CLOTHING_FUR, Item::DRINK_MEAD],[Item::CLOTHING_SILK])

  gemonia.add_region!("Janus",Region::SOUTHERN,2500,[metals],[carbonite],[Item::CLOTHING_SILK, Item::DRINK_WINE],[Item::CLOTHING_FUR, Item::DRINK_MEAD])
  gemonia.add_region!("Juno",Region::NORTHERN,2500,[carbonite],[metals],[Item::CLOTHING_FUR, Item::DRINK_MEAD],[Item::CLOTHING_SILK, Item::DRINK_WINE])

  libram.add_region!("Galilee",Region::NORTHERN,2000,[metals, carbonite],[fissile],[Item::FOOD_FISH],[Item::CLOTHING_CLOTH, Item::DRINK_BEER])
  libram.add_region!("Gehenna",Region::NORTHERN,3000,[metals, rare_elements],[fissile],[Item::CLOTHING_FUR],[Item::FOOD_GRAIN, Item::DRINK_WINE])
  libram.add_region!("Sinai",Region::NORTHERN,5000,[metals, fissile],[carbonite],[Item::DRINK_WINE],[Item::FOOD_MEAT, Item::FOOD_GRAIN])
  libram.add_region!("Judah",Region::SOUTHERN,1000,[carbonite, rare_elements],[fissile],[Item::CLOTHING_CLOTH],[Item::CLOTHING_FUR, Item::FOOD_GRAIN])
  libram.add_region!("Kidron",Region::SOUTHERN,1500,[carbonite, fissile],[rare_elements],[Item::DRINK_MEAD],[Item::FOOD_GRAIN, Item::DRINK_BEER])

  lyon.add_region!("Tumbra",Region::NORTHERN,7500,[],[fissile],[Item::FOOD_MEAT, Item::CLOTHING_FUR, Item::FOOD_GRAIN],[Item::CLOTHING_CLOTH, Item::CLOTHING_SILK])
  lyon.add_region!("Choka",Region::SOUTHERN,500,[metals],[],[Item::FOOD_MEAT, Item::FOOD_FISH],[Item::CLOTHING_SILK, Item::DRINK_MEAD, Item::FOOD_GRAIN])
  lyon.add_region!("Feral Islands",Region::SOUTHERN,500,[],[],[Item::FOOD_FISH, Item::DRINK_MEAD, Item::DRINK_BEER],[Item::FOOD_GRAIN, Item::CLOTHING_CLOTH, Item::DRINK_WINE])
  lyon.add_region!("Soma",Region::SOUTHERN,500,[fissile],[],[Item::FOOD_FISH, Item::DRINK_WINE],[Item::CLOTHING_FUR, Item::DRINK_BEER, Item::DRINK_MEAD])
  lyon.add_region!("Thar",Region::SOUTHERN,2500,[rare_elements],[],[Item::CLOTHING_SILK, Item::CLOTHING_CLOTH],[Item::CLOTHING_FUR, Item::DRINK_BEER, Item::DRINK_MEAD])
  lyon.add_region!("Singh",Region::SOUTHERN,2500,[carbonite],[],[Item::CLOTHING_SILK, Item::CLOTHING_CLOTH],[Item::CLOTHING_FUR, Item::DRINK_BEER, Item::DRINK_MEAD])

  orion.add_region!("Xion",Region::SOUTHERN,500,[metals,carbonite,rare_elements],[fissile],[],[Item::FOOD_GRAIN, Item::FOOD_FISH])
  orion.add_region!("Xodac",Region::NORTHERN,500,[metals,carbonite,rare_elements],[fissile],[],[Item::FOOD_GRAIN, Item::FOOD_FISH])
  orion.add_region!("Xerxes",Region::NORTHERN,500,[metals,carbonite,rare_elements],[fissile],[],[Item::FOOD_GRAIN, Item::FOOD_FISH])

  poisson.add_region!("Wallonia",Region::NORTHERN,4000,[metals],[rare_elements,fissile],[Item::DRINK_BEER],[Item::CLOTHING_SILK])
  poisson.add_region!("Dolphius",Region::NORTHERN,2500,[metals],[rare_elements,fissile],[Item::DRINK_WINE],[Item::CLOTHING_SILK])
  poisson.add_region!("Octovia",Region::NORTHERN,2500,[metals],[rare_elements,fissile],[Item::FOOD_GRAIN],[Item::CLOTHING_SILK])
  poisson.add_region!("Shul",Region::SOUTHERN,2500,[carbonite],[rare_elements,fissile],[Item::CLOTHING_FUR],[Item::CLOTHING_SILK])
  poisson.add_region!("Hok",Region::SOUTHERN,5000,[carbonite],[rare_elements,fissile],[Item::FOOD_FISH],[Item::CLOTHING_SILK])
  poisson.add_region!("Tym",Region::SOUTHERN,3000,[carbonite],[rare_elements,fissile],[Item::CLOTHING_SILK],[Item::DRINK_WINE])

  scorpia.add_region!("Great Marsh",Region::NORTHERN,5000,[carbonite,rare_elements],[metals],[Item::FOOD_FISH],[Item::CLOTHING_FUR,Item::CLOTHING_SILK])
  scorpia.add_region!("Helios Islands",Region::SOUTHERN,1500,[],[metals],[Item::FOOD_FISH,Item::DRINK_WINE,Item::CLOTHING_CLOTH],[Item::CLOTHING_FUR,Item::CLOTHING_SILK])
  scorpia.add_region!("Draconia",Region::SOUTHERN,1000,[metals],[carbonite],[Item::DRINK_MEAD,Item::FOOD_MEAT],[Item::DRINK_WINE,Item::CLOTHING_SILK])

  taura.add_region!("Basque",Region::NORTHERN,5000,[metals],[fissile],[Item::DRINK_MEAD,Item::FOOD_FISH],[Item::DRINK_WINE,Item::CLOTHING_SILK])
  taura.add_region!("Catyluca",Region::NORTHERN,4000,[metals],[fissile],[Item::DRINK_BEER,Item::FOOD_MEAT],[Item::DRINK_WINE,Item::CLOTHING_SILK])
  taura.add_region!("Anduluca",Region::SOUTHERN,2500,[rare_elements],[fissile],[Item::CLOTHING_SILK,Item::CLOTHING_CLOTH],[Item::FOOD_GRAIN,Item::FOOD_MEAT])
  taura.add_region!("Casilica",Region::NORTHERN,3000,[metals,carbonite],[fissile],[Item::DRINK_WINE],[Item::FOOD_FISH,Item::CLOTHING_SILK])

  virgil.add_region!("Eco",Region::NORTHERN,1000,[metals,rare_elements,fissile],[],[],[Item::FOOD_GRAIN,Item::FOOD_MEAT,Item::FOOD_FISH])
  virgil.add_region!("Geo",Region::NORTHERN,1000,[metals,rare_elements,fissile],[],[],[Item::FOOD_GRAIN,Item::FOOD_MEAT,Item::FOOD_FISH])
  virgil.add_region!("Aenid",Region::SOUTHERN,1500,[metals,rare_elements,fissile],[],[],[Item::FOOD_GRAIN,Item::FOOD_MEAT,Item::FOOD_FISH])

  Log.info "SEED", "Seeding World Markets"
  World.all.each{|world| world.seed_market! }
  
  Log.info "SEED", "Creating Ancient Houses"
  i = 0
  Region.all.each{|region| AncientHouse.create_ancient_house!(region, Names::HOUSE_NAMES[i]); i += 1}

end # transaction

