class Starship < ActiveRecord::Base
  attr_accessible :guid, :name, :noble_house, :noble_house_id, :starship_type, :starship_configuration, :built_date, :built_by, :built_location, :hulls_assembled, :captain, :captain_id, :hull_points, :location, :destroyed_date
  
  DEFENSE_DODGE = "dodging"
  DEFENSE_ENERGY = "shields"
  DEFENSE_ARMOUR = "armour"

  self.per_page = 15

  before_save :generate_guid
  
  validates_presence_of :name
  belongs_to :noble_house
  scope :of, lambda {|house|
    {:conditions => {:noble_house_id => house.id}}
  }
  
  belongs_to :starship_type
  belongs_to :starship_configuration
  
  game_date :built_date
  belongs_to :built_by, :class_name => 'Character'
  belongs_to :built_location, :class_name => 'Estate'
  validates_numericality_of :hulls_assembled, :only_integer => true
  belongs_to :captain, :class_name => 'Character'
  validates_numericality_of :hull_points, :only_integer => true

  has_many :sections, :dependent => :destroy
  has_many :crew, :dependent => :destroy
  has_many :scans, :dependent => :destroy

  game_date :destroyed_date

  include Locatable
  scope :at, lambda {|location|
    {:conditions => {:location_type => location.class.to_s, :location_id => location.id}}
  }

  scope :debris, :conditions => ['hull_points = 0 AND hulls_assembled <> 0']
  scope :not_debris, :conditions => ['hull_points > 0 AND hulls_assembled <> 0']

  include ItemContainer
  include Wealthy::NobleHousePosition
  include NewsLog
  include HousePosition
  include Starships

  after_initialize :set_totals

  def set_totals
    @effective_skill = {}
  end

  def self.build_starship!(name, starship_configuration, estate, fully_assembled=false)
    ss = create!(:name => name, :noble_house => estate.noble_house, :starship_type => starship_configuration.starship_type, :starship_configuration => starship_configuration,
            :built_by => estate.lord, :built_location => estate, :hulls_assembled => 0, :hulls_assembled => 0, :location => estate
      )
    estate.add_news!('SHIP_BUILD',starship_configuration.name)
    ss.assemble!(ss.starship_type.hull_size, false) if fully_assembled
    ss
  end

  def self.clear_debris!
    debris.select{|debris| debris.destroyed_date.years_ago >= 1 || debris.empty?}.each{|debris| debris.destroy}
  end

  def assemble!(hulls, remove_items=true)
    return true if built?
    hulls_needed = hull_size - self.hulls_assembled
    hulls = hulls_needed if hulls > hulls_needed
    if remove_items
      hulls_available = self.built_location.count_item(hull_type)
      hulls = hulls_available if hulls > hulls_available
      return false unless hulls > 0
      self.built_location.remove_item!(hull_type, hulls) 
    end
    self.hulls_assembled = self.hulls_assembled + hulls 
    if built?
      self.built_date = Game.current_date
      self.hull_points = max_hull_points
      self.starship_configuration.starship_configuration_items.each do |sci|
        item = sci.item
        quantity = sci.quantity
        install!(item, quantity, remove_items) if quantity > 0
      end
      add_news!('SHIP_COMPLETED', location)
    end
    save!
    true
  end

  def refit!(remove_items=true)
    return 0 unless location_estate? && !foreign_to?(self.location)
    install_count = 0
    self.starship_configuration.starship_configuration_items.each do |sci|
      item = sci.item
      quantity = sci.quantity - count_section(item)
      install_count += install!(item, quantity, remove_items) if quantity > 0
    end
    add_news!('SHIP_REFIT',"Estate #{self.location.name}") if install_count > 0
    install_count
  end

  def allocate_damage!(damage)
    damage = self.hull_points if damage > self.hull_points
    update_attributes!(:hull_points => (self.hull_points - damage))
    broken = false
    exploded = false
    if self.hull_points < 1
      explode!
      exploded = true
    elsif integrity_breakdown_chance.success?
      breakdown!
      broken = true
    end
    return broken, exploded
  end

  def hull_type?(hull)
    return false unless hull
    self.starship_type.hull_type_id == hull.id
  end

  def damage
    max_hull_points - self.hull_points
  end

  def damage_ratio
    (damage / max_hull_points)
  end

  def hull_integrity
    ((hull_points / max_hull_points.to_f) * 100).round(0).to_i
  end

  def hull_damage
    100 - hull_integrity
  end

  def built?
    !(self.hulls_assembled < hull_size)
  end

  def lost?
    destroyed? || debris?
  end

  def debris?
    self.hull_points < 1
  end

  def damaged?
    self.hull_points < max_hull_points
  end

  def has_bridge?
    metrics[:bridge]
  end

  def captain_and_crew
    (Crew.onboard(self).map{|crew| crew.character}.to_a + [self.captain])
  end

  def lieutenants
    Crew.onboard(self).lieutenants
  end

  def ensigns
    Crew.onboard(self).ensigns
  end

  def best_ranked_skill(skill)
    best = 0
    self.crew.each{|crew| v = best_skill(self.captain,crew,skill); best = v if v > best }
    best
  end

  def count_section(item)
    section = Section.find_by_starship_id_and_item_id(self.id, item.id)
    section ? section.quantity : 0
  end

  def has_section?(item)
    count_section(item) > 0
  end

  def armour_sections
    Section.on(self).of_type(Item::ARMOUR)
  end

  def armour_sections_count
    armour_sections.sum{|section| section.quantity}
  end

  def command_sections
    Section.on(self).of_type(Item::COMMAND)
  end

  def command_sections_count
    command_sections.sum{|section| section.quantity}
  end

  def mission_sections
    Section.on(self).of_type(Item::MISSION)
  end

  def mission_sections_count
    mission_sections.sum{|section| section.quantity}
  end

  def engine_sections
    Section.on(self).of_type(Item::ENGINE)
  end

  def engine_sections_count
    engine_sections.sum{|section| section.quantity}
  end

  def utility_sections
    Section.on(self).of_type(Item::UTILITY)
  end

  def utility_sections_count
    utility_sections.sum{|section| section.quantity}
  end

  def primary_sections
    Section.on(self).from_types(Item::SHIP_PRIMARY_WEAPONS)
  end

  def primary_sections_count
    primary_sections.sum{|section| section.quantity}
  end

  def spinal_sections
    Section.on(self).of_type(Item::SPINAL_MOUNT)
  end

  def spinal_sections_count
    spinal_sections.sum{|section| section.quantity}
  end

  def space_to_install(item)
    return case item.category
    when Item::ARMOUR
      self.starship_type.armour_slots - armour_sections_count
    when Item::COMMAND
      self.starship_type.command_slots - command_sections_count
    when Item::MISSION
      self.starship_type.mission_slots - mission_sections_count
    when Item::ENGINE
      self.starship_type.engine_slots - engine_sections_count
    when Item::UTILITY
      self.starship_type.utility_slots - utility_sections_count
    when Item::LAUNCHER
      self.starship_type.primary_slots - primary_sections_count
    when Item::BEAM_WEAPON
      self.starship_type.primary_slots - primary_sections_count
    when Item::KINETIC_WEAPON
      self.starship_type.primary_slots - primary_sections_count
    when Item::SPINAL_MOUNT
      self.starship_type.spinal_slots - spinal_sections_count
    else
      0
    end
  end

  def can_install?(item, quantity=1)
    space_to_install(item) >= quantity
  end

  def best_defense(weapon,effective_speed=ship_speed)
    return nil unless weapon
    dodge = dodge_save_chance(weapon.weapon_speed,effective_speed)
    energy = energy_save_chance ? energy_save_chance - weapon.shield_piercing : 0
    armour = armour_save_chance
    best_type = nil
    best = nil 
    if dodge > energy
      best_type = DEFENSE_DODGE
      best = dodge
    else
      best_type = DEFENSE_ENERGY
      best = energy
    end
    if armour > best
      best_type = DEFENSE_ARMOUR
    end
    best_type
  end

  def best_save_chance(weapon,effective_speed=ship_speed)
    return "0".chance unless weapon
    dodge = dodge_save_chance(weapon.weapon_speed)
    energy = energy_save_chance ? energy_save_chance - weapon.shield_piercing : 0
    armour = armour_save_chance
    best = dodge > energy ? dodge : energy
    best = armour > best ? armour : best
    best
  end

  def armour_save_chance
    @armour_save_chance ||= metrics[:armour_save]
  end

  def ship_speed
    @ship_speed ||= metrics[:ship_speed]
  end

  def faster?(other_ship)
    faster_speed?(self.ship_speed,other_ship.ship_speed)
  end

  def dodge_save_chance(weapon_speed,effective_speed=ship_speed)
    return case weapon_speed
    when Item::FAST
      case effective_speed
      when Starships::SPEED_SLOW
        "0".chance
      when Starships::SPEED_NORMAL
        "0".chance
      when Starships::SPEED_FAST
        "10 on 1d10".chance + effective_piloting
      end
    when Item::MEDIUM
      case effective_speed
      when Starships::SPEED_SLOW
        "0".chance
      when Starships::SPEED_NORMAL
        "10 on 1d10".chance + effective_piloting
      when Starships::SPEED_FAST
        "9 on 1d10".chance + effective_piloting
      end
    when Item::SLOW
      case effective_speed
      when Starships::SPEED_SLOW
        "10 on 1d10".chance + effective_piloting
      when Starships::SPEED_NORMAL
        "9 on 1d10".chance + effective_piloting
      when Starships::SPEED_FAST
        "8 on 1d10".chance + effective_piloting
      end
    end
  end

  def weapons_by_speed(weapon_speed)
    metrics[:space_weapons] ? metrics[:space_weapons].select{|section| section.item.weapon_speed == weapon_speed} : []
  end

  def energy_save_chance
    metrics[:energy_save]
  end

  def worker_space_total
    sum_section_item_function(:worker_capacity)
  end

  def troop_space_total
    sum_section_item_function(:troop_capacity)
  end

  def ammo_space_total
    sum_section_item_function(:ammo_capacity)
  end

  def ore_space_total
    sum_section_item_function(:ore_capacity)
  end

  def cargo_space_total
    sum_section_item_function(:cargo_capacity)
  end

  def worker_space_used
    sum_mass_category(Item::WORKER)
  end

  def troop_space_used
    sum_mass_category(Item::TROOP) + sum_embarked_army_troop
  end

  def ammo_space_used
    sum_mass_categories(Item::AMMO)
  end

  def ore_space_used
    sum_mass_category(Item::ORE)
  end

  def cargo_space_used
    sum_mass_categories(Item::CARGO) + sum_embarked_army_cargo - (ore_space_used + ammo_space_used)
  end

  def space_available(category)
    if Item::WORKER == (category)
      worker_space_total - worker_space_used
    elsif Item::TROOP == (category)
      troop_space_total - troop_space_used
    elsif Item::AMMO.include?(category)
      ammo_space_total - ammo_space_used
    elsif Item::ORE == (category)
      ore_space_total - ore_space_used
    elsif Item::CARGO.include?(category)
      cargo_space_total - cargo_space_used
    else
      0
    end
  end

  def space_for_army?(army)
    !((troop_space_used + army.total_troops) > troop_space_total || (cargo_space_used + army.embarkation_cargo_space > cargo_space_total))
  end

  def sensor_power
    metrics[:sensor_power]
  end

  def jammer_chance
    metrics[:jammer_chance]
  end

  def thrust_speed
    metrics[:thrust_speed]
  end

  def impulse_speed
    metrics[:impulse_speed]
  end

  def impulse_modifier
    (metrics[:impulse_modifier] ? metrics[:impulse_modifier] : 0)
  end

  def can_take_off?
    (!light_hull? && thrust_speed && thrust_speed >= 1) || (location_estate? && location.orbital_dock?)
  end

  def can_dock?(estate)
    return false if location_estate?
    return true if estate.orbital_dock?
    return false if light_hull?
    thrust_speed && thrust_speed >= 1
  end

  def can_move?
    return false if location_estate?
    impulse_speed && impulse_speed > 0
  end

  def can_trade?
    return true if location_estate?
    metrics[:orbital_trade]
  end

  def can_trade_with?(estate)
    return true if estate && location_type == 'Estate' && location_id == estate.id
    return true if metrics[:orbital_trade] && current_world.id == estate.region.world_id
    false
  end

  def onboard?(character)
    character.location_type == 'Starship' && character.location_id == self.id
  end

  def assign_captain!(character)
    if self.captain
      t = Title.belonging_to(self.captain).starship(self).category(Title::CAPTAIN).first 
      t.revoke!  if t
    end
    self.captain_id = character.id
    save!
    Title.appoint_captain!(character, self)
  end

  def unassign_captain!
    return false unless self.captain
    t = Title.belonging_to(self.captain).starship(self).category(Title::CAPTAIN).first
    t.revoke! if t
    self.captain = nil
    save!
  end

  def embark_character!(character)
    return false unless has_bridge? && !debris?
    unless self.captain || !character.adult?
      assign_captain!(character)
    else
      Crew.assign_crew!(self, character)
    end
    true
  end

  def disembark_character!(character)
    return false unless location_estate? && character
    if self.captain_id == character.id
      unassign_captain!
    else
      Crew.unassign_crew!(self, character)
    end
    character.disembark_starship!
  end

  def embark_army!(army)
    return false unless army && army.location_type == self.location_type && army.location_id == self.location_id && space_for_army?(army)
    army.location = self
    army.save!
    army.add_news!('ARMY_EMBARK',self)
  end

  def disembark_army!(army)
    return false unless army && army.location = self
    army.location = self.location
    army.save!
    army.add_news!('ARMY_DISEMBARK',self)
  end

  def calculate_movement_cost(world)
    quad_diff = World.quad_distance(self.current_world,world)
    dist_diff = (current_world.distance - world.distance).abs
    speed_modifier = impulse_speed.to_f + impulse_modifier.to_f
    speed_modifier = 0.1 if speed_modifier < 0.1
    ap_cost = (quad_diff * 4) + dist_diff
    ap_cost = ap_cost.to_f * speed_modifier
    ap_cost = ap_cost.round(0).to_i
  end

  def cloaked_move?
    metrics[:cloak]
  end

  def has_escape_pods?
    metrics[:escape_pod]
  end

  def has_nano_repair?
    metrics[:nano_repair]
  end

  def take_off!
    return false unless can_take_off?
    self.location = current_world
    save!
    add_news!('SHIP_TAKE_OFF',current_world)
    scan_orbit!
  end

  def dock!(estate)
    return false unless can_dock?(estate)
    self.location = estate
    save!
    add_news!('SHIP_DOCKED', estate)
  end

  def move!(world)
    return false unless can_move?
    self.location = world
    save!
    add_news!('SHIP_MOVED', world)
    scan_orbit!(cloaked_move?)
  end

  def orbiting?(world=nil)
    return false unless location_type == 'World'
    world ? self.location.id == world.id : true
  end

  def scanned?(ship)
    return false unless orbiting?
    Scan.at(self.location).of(ship).by_house(self.noble_house).size > 0
  end

  def jammer_success?
    jammer_chance && jammer_chance.success?
  end

  def scan_success?(ship)
    chance = sensor_power ? sensor_power + ship.sensor_profile_modifier : "0".chance
    chance.success? && !ship.jammer_success?
  end

  def scan_orbit!(cloaked=false)
    return false unless orbiting? && sensor_power && sensor_power != 0
    scanned = false
    Starship.at(location).each do |ship|
      unless ship.id == self.id || ship.noble_house_id == self.noble_house_id
        if !scanned?(ship) && scan_success?(ship)
          Scan.scanned!(self, ship, location) 
          scanned = true
        end
        Scan.scanned!(ship, self, location) unless cloaked || ship.scanned?(self) || !ship.scan_success?(self)
      end
    end
    scanned
  end

  def scanned
    Scan.by_house(self.noble_house).at(self.location).select{|scan| !scan.target.nil? && !scan.target.destroyed?}
  end

  def scanned_of_house(house)
    Scan.by_house(self.noble_house).at(self.location).of_house(house).select{|scan| !scan.target.nil? && !scan.target.destroyed?}
  end

  def effective_melee
    Skill.best_skill(captain_and_crew, Skill::MILITARY_MELEE)
  end

  def effective_navigation
    Skill.best_skill(captain_and_crew, Skill::NAVAL_NAVIGATION)
  end

  def effective_piloting
    Skill.best_skill(captain_and_crew, Skill::NAVAL_PILOTING)
  end

  def effective_shooting
    Skill.best_skill(captain_and_crew, Skill::NAVAL_SHOOTING)
  end

  def effective_electronics
    Skill.best_skill(captain_and_crew, Skill::NAVAL_ELECTRONICS)
  end

  def effective_damage_control
    Skill.best_skill(captain_and_crew, Skill::NAVAL_DAMAGE_CONTROL)
  end

  def effective_medicine
    Skill.best_skill(captain_and_crew, Skill::CHURCH_MEDICINE)
  end

  def effective_tactics
    a = Skill.best_skill(captain_and_crew,Skill::MILITARY_TACTICS)
    b = Skill.best_skill(captain_and_crew,Skill::MILITARY_MELEE)
    a > b ? a : b
  end

  def effective_fortification
    0
  end

  def effective_explosives
    0
  end

  def explode!
    unless has_escape_pods?
      # destroy cargo
      bundles.each{|ib| ib.destroy }
      # destroy armies
      embarked_armies.each{|army| army.killed! }
      # kill characters
      Character.at(self).each do |c|
        c.die!("ship exploding")
      end
      add_news!('SHIP_EXPLODE',location)
      destroy
      return true
    else
      return breakdown!
    end
  end

  def breakdown!
    update_attributes!(:hull_points => 0, :destroyed_date => Game.current_date)
    # convert all sections into cargo
    sections.each do |section|
      add_item!(section.item, section.quantity)
      section.destroy
    end
    Character.at(self).each do |c|
      c.move_to_nearest_estate!
    end
    Army.at(self).each do |army|
      disembark_army!(army)
    end
    save!
    add_news!('SHIP_BREAKDOWN',location)
    true
  end

  def integrity_breakdown_chance
    "#{self.hull_integrity} on 1d20".chance
  end

  def attack!(ship)
    return false unless orbiting? && self.noble_house.at_war?(ship.noble_house)
    scan_orbit!
    return false unless scanned?(ship)
    return true if SpaceBattle.fight!(self,ship)
    false
  end

  def attack_house_ship!(house,target_hull_type=nil,min_hull_size=1,max_hull_size=1000,min_damage=0,max_damage=99)
    return false unless orbiting? && self.noble_house.at_war?(house)
    scan_orbit!
    candidates = scanned_of_house(house).select do |scan|
      (target_hull_type.nil? || scan.target.hull_type?(target_hull_type)) &&
      (scan.target.hull_size >= min_hull_size) &&
      (scan.target.hull_size <= max_hull_size) &&
      (scan.target.hull_damage >= min_damage) &&
      (scan.target.hull_damage <= max_damage)
    end
    return attack!(candidates.sample.target) if candidates.size > 0
    false
  end

  def bombard!(estate)
    return false unless orbiting?
    # TODO bombard
  end

  def capture!(ship)
    return false unless orbiting?
    scan_orbit!
    return false unless scanned?(ship)
    return true if GroundBattle.fight!(self,ship)
    false
  end

  def repair!(character)
    transaction do
      repair_skill = character.skill_rank(Skill::NAVAL_REPAIR)
      max_repair = 100 + (25 * repair_skill)
      max_repair = damage if damage < max_repair
      cost = has_nano_repair? ? 25 : 50 
      metal = Item.named('Metals').first
      carbon = Item.named('Carbonite').first
      # TODO check for Spirit of the Living
      metals = count_item(metal)
      carbons = count_item(carbon)
      unless orbiting?
        metals = metals + location.count_item(metal)
        carbons = carbons + location.count_item(carbon)
      end
      max_materials = (metals / cost).to_i
      max_repair = max_materials if max_materials < max_repair
      max_materials = (carbons / cost).to_i
      max_repair = max_materials if max_materials < max_repair
      update_attributes!(:hull_points => self.hull_points + max_repair)
      use_materials = max_repair * cost
      metals = count_item(metal)
      carbons = count_item(carbon)
      if metals < use_materials
        remove_item!(metal,metals)  
        location.remove_item!(metal, (use_materials - metals))
      else
        remove_item!(metal,use_materials)
      end
      if carbons < use_materials
        remove_item!(carbon,carbons)
        location.remove_item!(carbon,(use_materials - carbons))
      else
        remove_item!(carbon,use_materials)
      end
      add_news!('REPAIR', "#{max_repair}") if max_repair > 0
      max_repair
    end
  end

  def ammo_for(weapon)
    return nil unless weapon
    if weapon.torpedo_launcher?
      bundles_of_type(Item::TORPEDO)
    elsif weapon.missile_launcher?
      bundles_of_type(Item::MISSILE)
    else
      nil
    end
  end

  def drones
    bundles_of_type(Item::DRONE)
  end

  def install!(item, quantity=1, remove_items=true)
    return 0 unless can_install?(item)
    section = Section.find_or_create_by_starship_id_and_item_id(self.id, item.id)
    section.quantity = 0 unless section.quantity
    space_avail = space_to_install(item)
    quantity = space_avail if quantity > space_avail
    if remove_items
      if location_estate? && !location_foreign?
        quantity_available = location.count_item(item)
        quantity = quantity_available if quantity > quantity_available
        location.remove_item!(item, quantity)
      else
        quantity = 0
      end
    end
    section.quantity = section.quantity + quantity
    section.save!
    add_news!('SHIP_INSTALLED', "#{quantity} x #{item.name}") if quantity > 0
    quantity
  end

  def uninstall!(item, quantity=1,add_items=true)
    section = Section.find_by_starship_id_and_item_id(self.id, item.id)
    return 0 unless section
    quantity = section.quantity if section.quantity < quantity
    section.quantity = section.quantity - quantity
    if add_items
      self.location.add_item!(item, quantity) if location_estate? && !location_foreign?
    end
    section.save!
    add_news!('SHIP_UNINSTALLED', "#{quantity} x #{item.name}") if quantity > 0
    quantity
  end

  def load_cargo!(estate,item,quantity)
    return false unless can_trade_with?(estate)
    if foreign_to?(estate)
      quantity = Authorisation.pickup!(estate,self,item,quantity)
    else
      quantity = estate.transfer_items!(self, item, quantity)
    end
    add_news!('SHIP_LOAD_CARGO', "#{quantity} x #{item.name} from Estate #{estate.name}")
    unless self.noble_house_id == estate.noble_house_id
      estate.add_news!('ESTATE_SHIP_LOAD_CARGO', "#{self.name} picked up #{quantity} x #{item.name}")
    end
    quantity
  end

  def unload_cargo!(estate,item,quantity)
    return false unless can_trade_with?(estate)
    return false if foreign_to?(estate) && !Authorisation.has_delivery_rights?(estate, noble_house)
    if item
      quantity = transfer_items!(estate, item, quantity)
      add_news!('SHIP_UNLOAD_CARGO', "#{quantity} x #{item.name} to Estate #{estate.name}")
      unless self.noble_house_id == estate.noble_house_id
        estate.add_news!('ESTATE_SHIP_UNLOAD_CARGO', "#{self.name} delivered #{quantity} x #{item.name}")
      end
      return quantity
    else
      bundles.each do |ib|
        unload_cargo!(estate,ib.item,ib.quantity) unless ib.item.troop?
      end
    end
  end

  def load_workers!(category,quantity)
    return false unless location_estate? && !foreign_to?(location)
    quantity = Population.load_population!(location, self, category, quantity)
    add_news!('SHIP_LOAD_WORKERS',"#{quantity} x #{category} workers picked up from Estate #{location.name}")
    # location.add_news!('ESTATE_SHIP_LOAD_WORKERS', "#{self.name} picked up #{quantity} x #{category} workers")
  end

  def unload_workers!(item, quantity)
    return false unless location_estate? && !foreign_to?(location)
    quantity = Population.unload_population!(location, self, item, quantity)
    add_news!('SHIP_UNLOAD_WORKERS',"#{quantity} x #{item.name} delivered to Estate #{location.name}")
    # location.add_news!('ESTATE_SHIP_UNLOAD_WORKERS', "#{self.name} delivered #{quantity} x #{item.name}")
  end

  def salvage!(ship)
    return false unless orbiting? && scanned?(ship) && ship.debris?
    ship.bundles.each do |bundle|
      ship.transfer_items!(self, bundle.item, bundle.quantity)
    end
    add_news!('SHIP_SALVAGE',ship)
  end

  def status_text
    return "Under Construction (#{hulls_assembled} / #{self.starship_type.hull_size})" unless built?
    return "Debris" if debris?
    return "Damaged (#{hull_integrity}% hull integrity)" if damaged?
    return "Docked at #{location.name}" if location_estate?
    return "Orbiting #{location.name}" if location_world?
    "Unknown"
  end

  def metrics
    m = calculate_metrics(self.sections)
    m[:accuracy_modifier] = m[:accuracy_modifier] ? m[:accuracy_modifier] + effective_shooting : effective_shooting
    m[:impulse_modifier] = m[:impulse_modifier] ? m[:impulse_modifier] - (effective_navigation * 0.1) : 0 - (effective_navigation * 0.1)
    m[:energy_save] = m[:energy_save] ? m[:energy_save] + effective_electronics : nil
    m
  end

  def embarked_armies
    Army.at(self)
  end

  def to_s
    "House #{self.noble_house.name} - #{self.name}"
  end

  private
  def sum_embarked_army_cargo
    embarked_armies.sum{|army| army.sum_mass_categories(Item::CARGO)}
  end
  def sum_embarked_army_troop
    embarked_armies.sum{|army| army.sum_mass_category(Item::TROOP)}
  end

  def sum_section_item_function(function)
    total = 0
    self.sections.each {|section| total += (section.item.send(function) * section.quantity)}
    total
  end

end
