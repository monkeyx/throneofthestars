class Estate < ActiveRecord::Base
  attr_accessible :guid, :region, :noble_house, :noble_house_id, :name, :build_date, :captured_date, :destroyed_date, :lord, :steward, :tribune, :lands, :taxes, :slave_wages, :freemen_wages, :artisan_wages
  
  self.per_page = 15  

  RENT_MULTIPLIER = 0.05
  
  before_save :generate_guid
  after_save  :destroy_empty_populations, :set_totals
  
  belongs_to :region
  belongs_to :noble_house
  validates_presence_of :name
  validate :unique_name_per_region
  game_date :build_date
  game_date :captured_date
  game_date :destroyed_date
  belongs_to :lord, :class_name => 'Character'
  belongs_to :steward, :class_name => 'Character'
  belongs_to :tribune, :class_name => 'Character'
  belongs_to :deacon, :class_name => 'Character'
  validates_numericality_of :lands, :only_integer => true
  validates_numericality_of :taxes
  validates_numericality_of :slave_wages
  validates_numericality_of :freemen_wages
  validates_numericality_of :artisan_wages

  has_many :buildings, :dependent => :destroy
  has_many :populations, :dependent => :destroy
  has_many :authorisations, :dependent => :destroy
  has_many :production_queues, :dependent => :destroy
  has_many :weddings, :dependent => :destroy
  has_many :prisoners, :dependent => :destroy
  has_many :tournaments, :dependent => :destroy, :order => 'event_date DESC, created_at DESC'

  has_many :titles, :dependent => :destroy

  include ItemContainer
  include Wealthy::NobleHousePosition
  include NewsLog
  include HousePosition

  scope :on, lambda {|world|
    {:conditions => ["region_id IN (?)",world.regions]}
  }

  scope :at, lambda {|region|
    {:conditions => {:region_id => region.id}}
  }

  scope :of, lambda {|house|
    {:conditions => {:noble_house_id => house.id}}
  }

  def self.build!(noble_house,region,name,build_date=Game.current_date)
    estate = create!(:region => region, :noble_house => noble_house, :name => name,
            :build_date => build_date, :lord => noble_house.baron,
            :slave_wages => 1, :freemen_wages => 1, :artisan_wages => 5
    )
    estate.add_news!("ESTATE_BUILT",false,false,build_date)
    estate
  end

  after_initialize :set_totals

  def set_totals
    @building_functions = {}
    @total_shuttle_capacity = nil
    @total_shuttle_used = nil
    @total_tithe_modifier = nil
    @total_production_capacity = nil
    @total_land_used = nil
    @free_lands = nil
    @worker_count = {}
    @worker_morale = {}
    @worker_savings = {}
    @worker_required = {}
    @worker_capacity = {}
    @effective_skill = {}
    @building_levels = {}
    @efficiency = {}
    calculate_efficiency
  end

  def set_wage_levels!(slaves,freemen,artisans)
    update_attributes!(:slave_wages => slaves, :freemen_wages => freemen, :artisan_wages => artisans)
    add_news!('SET_WAGES',"&pound;#{slaves} to slaves, &pound;#{freemen} to freemen and &pound;#{artisans} to artisans")
    true
  end

  def total_land_used
    self.buildings.to_a.sum{|b| b.level}
  end

  def free_land
    self.lands - total_land_used
  end

  alias_method :free_lands, :free_land

  def has_space?
    free_land > 0
  end

  def add_lands!(qty)
    self.lands += qty
    save!
  end

  def subtract_lands!(qty)
    self.lands -= qty
    save!
  end

  def claim_lands!(qty,price_to_pay=self.region.land_cost)
    price_to_pay *= (1.0 - (effective_barter * 0.1))
    qty = self.region.unclaimed_lands if qty > self.region.unclaimed_lands
    max_afford = price_to_pay > 0 ? (self.noble_house.wealth / price_to_pay).to_i : qty
    qty = max_afford if qty > max_afford
    transaction do
      self.noble_house.subtract_wealth!(qty * price_to_pay) if price_to_pay > 0
      self.region.update_attributes!(:unclaimed_lands => self.region.unclaimed_lands - qty)
      add_lands!(qty)
    end
    add_news!("CLAIMED_LANDS", qty) if qty > 0
    qty
  end

  def trade_lands!(other_estate,qty)
    return 0 - other_estate.trade_lands!(qty.abs) if qty < 0
    qty = free_land if free_land < qty
    transaction do
      subtract_lands!(qty)
      other_estate.add_lands!(qty)
    end
    add_news!("TRADE_LANDS",other_estate)
    self.lands
  end

  def residents
    Character.at(self)
  end

  def add_population!(worker_type,quantity)
    Population.add_population!(self, worker_type, quantity)
  end

  def subtract_population!(worker_type,quantity)
    Population.subtract_population!(self, worker_type, quantity)
  end

  def transfer_population!(from_category,to_category,quantity)
    Population.transfer_population!(self, from_category, to_category, quantity)
  end

  def population_type(worker_type)
    self.populations.find(:first,:conditions => {:category => worker_type})
  end

  def worker_count(worker_type)
    unless @worker_count[worker_type]
      worker = population_type(worker_type)
      @worker_count[worker_type] = worker.nil? ? 0 : worker.quantity
    end
    @worker_count[worker_type]
  end

  def worker_morale(worker_type)
    unless @worker_morale[worker_type]
      worker = population_type(worker_type)
      @worker_morale[worker_type] ||= worker.nil? ? 0 : worker.morale
    end
    @worker_morale[worker_type]
  end

  def worker_savings_per_person(worker_type)
    unless @worker_savings[worker_type]
      worker = population_type(worker_type)
      @worker_savings[worker_type] = worker.nil? || worker.quantity < 1 ? 0 : worker.wealth / worker.quantity
    end
    @worker_savings[worker_type]
  end

  def workers_required(worker_type)
    @worker_required[worker_type] ||= self.buildings.to_a.sum{|building| building.count_workers_needed(worker_type)}
  end

  def worker_capacity(worker_type)
    unless @worker_capacity[worker_type]
      required = workers_required(worker_type)
      if required == 0
        @worker_capacity[worker_type] = 1 # 100% if none of this type required
      else
        capacity = worker_count(worker_type).to_f / required
        capacity += effective_organization if capacity < 1
        capacity = 1 if capacity > 1
        @worker_capacity[worker_type] = capacity
      end
    end
    @worker_capacity[worker_type]
  end

  def effective_management
    @effective_skill[:management] ||= Skill.best_skill([self.lord,self.steward],Skill::CIVIL_MANAGEMENT)
  end

  def effective_barter
    @effective_skill[:barter] ||= Skill.best_skill([self.lord,self.steward],Skill::CIVIL_BARTER)
  end

  def effective_recruitment
    @effective_skill[:recruitment] ||= Skill.best_skill([self.lord,self.tribune],Skill::CIVIL_RECRUITMENT)
  end

  def effective_organization
    @effective_skill[:organization] ||= Skill.best_skill([self.lord,self.steward],Skill::CIVIL_ORGANIZATION)
  end

  def effective_biogenics
    @effective_skill[:biogenics] ||= Skill.best_skill([self.lord,self.steward],Skill::CHURCH_BIOGENICS)
  end

  def effective_automation
    @effective_skill[:automation] ||= Skill.best_skill([self.lord,self.steward],Skill::CHURCH_AUTOMATION)
  end

  def effective_engineering
    @effective_skill[:engineering] ||= Skill.best_skill([self.lord,self.steward],Skill::CIVIL_ENGINEERING)
  end

  def effective_medicine
    Skill.best_skill([self.lord,self.steward,self.tribune],Skill::CHURCH_MEDICINE)
  end

  def effective_tactics
    Skill.best_skill([self.lord,self.steward,self.tribune],Skill::MILITARY_TACTICS)
  end

  def effective_reconnaissance
    Skill.best_skill([self.lord,self.steward,self.tribune],Skill::MILITARY_RECON)
  end

  def effective_fortification
    Skill.best_skill([self.lord,self.steward,self.tribune],Skill::MILITARY_FORTIFICATIONS)
  end

  def effective_explosives
    Skill.best_skill([self.lord,self.steward,self.tribune],Skill::MILITARY_EXPLOSIVES)
  end

  def has_building?(building_type)
    building_level(building_type) > 0
  end

  def building_level(building_type)
    unless @building_levels[building_type]
      list = Building.at(self).building_type(building_type)
      @building_levels[building_type] = list.size > 0 ? list.first.level : 0
    end
    @building_levels[building_type]
  end

  def set_tax_level!(new_level)
    return false unless new_level >= 0
    update_attributes!(:taxes => new_level)
    add_news!("TAX_LEVEL", "#{money(new_level)}")
  end

  def can_collect_taxes?
    @can_collect_taxes ||= has_building_function?(:collect_taxes?)
  end

  def can_sell_on_market?
    @can_sell_on_market ||= has_building_function?(:trade_hall?)
  end

  def can_make_items?
    @can_make_items ||= has_building_function?(:can_make_items?)
  end

  def can_build_ships?
    @can_build_ships ||= has_building_function?(:can_build_ships?)
  end

  def can_join_clergy?
    @can_join_clergy ||= has_building_function?(:can_join_clergy?)
  end

  def orbital_dock?
    @orbital_dock ||= has_building_function?(:orbital_dock?)
  end

  def tithe_allowed?
    @tithe_allowed ||= has_building_function?(:can_tithe?)
  end

  def tithe_modifier
    return 0 unless tithe_allowed?
    @total_tithe_modifier ||= (1.0 + Building.sum_tithe_modifier(self))
  end

  def automated_resource_gathering!
    total = 0
    self.buildings.each {|building| q = building.gather_resources!; total += q if q}
    total
  end
  
  def produce_item!(item, quantity)
    return false unless has_raw_materials(item) > 0
    return false if item.restricted? && !self.region.world.has_project?(item.project_required)
    raw_items_for = has_raw_materials(item)
    quantity = raw_items_for if raw_items_for < quantity
    if quantity > 0
      transaction do
        use_raw_materials(item, quantity)
        add_item!(item, quantity)
        add_news!("PRODUCTION","#{quantity} x #{item.name.pluralize_if(quantity)}")
      end
    end
    quantity
  end

  def automated_production!
    total_production_capacity # sets @total_production_capacity
    queue = self.production_queues
    qi = nil
    i = 0
    while @total_production_capacity > 0 && i < queue.size do
      qi = queue[i]
      item = qi.item
      qty = qi.quantity
      capacity_for = item.mass > 0 ? (@total_production_capacity / item.mass).to_i : 0
      qty = capacity_for if capacity_for < qty
      if qty < 1 # not enough capacity for one
         i = queue.size
         qi.add_capacity!(@total_production_capacity)
         use_production_capacity!(@total_production_capacity)
         @total_production_capacity = 0
      else
        qty_built = produce_item!(item, qty)
        if qty_built
          production_used = qty_built > 0 ? qty_built * item.mass : 0
          if @total_production_capacity < item.mass
            qi.add_capacity!(@total_production_capacity)
            use_production_capacity!(@total_production_capacity)
            @total_production_capacity = 0
          else
            use_production_capacity!(production_used)
            @total_production_capacity -= production_used
          end
          if qi.quantity == qty_built
            qi.destroy
          else
            qi.subtract_quantity!(qty_built)
          end
        end
        return if @total_production_capacity < 1
      end
      i += 1
    end
  end

  def automated_recruitment!
    self.buildings.each {|building| building.recruit!}
  end

  def automated_market_sales!
    sell_resource_bundles!(bundles_of_type(Item::ORE))
    sell_resource_bundles!(bundles_of_type(Item::TRADE_GOOD))
    spare_freemen = workers_required(Item::FREEMEN_WORKER) - worker_count(Item::FREEMEN_WORKER)
    sell_worker!(Item::FREEMEN_WORKER, spare_freemen, 10) if spare_freemen > 0
  end

  def sell_resource_bundles!(bundles)
    bundles.each do |ib|
      resource_yield = self.region.current_resource_yield(ib.item)
      resource_yield = 0.001 if resource_yield == 0
      price = (50.0 / resource_yield).round(2)
      MarketItem.sell_item!(self, self.region.world, ib.item, ib.quantity, price)
    end
  end

  def sell_worker!(worker_type, quantity,price)
    item = Item.source(self.region.world).worker(worker_type).first
    MarketItem.sell_item!(self, self.region.world, item, quantity, price)
  end

  def construct!(building_type,skip_materials=false,construction_date=Game.current_date)
    building = Building.build!(self, building_type,skip_materials)
    return false unless building
    if building.level == 1
      add_news!("BUILDING_CONSTRUCTED",building,false,false,construction_date)
    else
      add_news!("BUILDING_UPGRADED",building,false,false,construction_date)
    end
    building
  end

  def demolish!(building_type, levels=1,sabotage=false)
    list = Building.at(self).building_type(building_type)
    if list.size > 0
      b = list.first
      levels = b.demolish!(levels)
      add_news!("BUILDING_DEMOLISHED","#{levels} " + "level".pluralize_if(levels)  + " of #{building_type.category}") unless sabotage
      return levels
    end
    false
  end

  def rents
    return @rent_price if @rent_price
    @rent_price = (self.region.land_cost * RENT_MULTIPLIER).to_i
    @rent_price = @rent_price * self.lands
  end

  def collect_rents!
    r = rents
    self.noble_house.add_wealth!(r)
    add_news!("COLLECT_RENT",money(r))
  end

  def troop_wages
    @troop_wages ||= sum_category_quantity(Item::TROOP)
  end

  def emancipation!
    freemen_required = workers_required(Item::FREEMEN_WORKER)
    freemen_available = worker_capacity(Item::FREEMEN_WORKER)
    slaves_available = worker_capacity(Item::SLAVE_WORKER)
    slaves_required = workers_required(Item::SLAVE_WORKER)
    slaves_eligible = 0
    slaves_eligible = slaves_required - slaves_available if slaves_available && slaves_required
    if freemen_available < 1 && freemen_required > 0 && slaves_eligible > 0
      slaves_freed = freemen_required
      slaves_freed = 0
      slaves_freed = slaves_eligible if slaves_freed > slaves_eligible
      transaction do
        if slaves_freed > 0
          subtract_population!(Item::SLAVE_WORKER, slaves_freed)
          add_population!(Item::FREEMEN_WORKER,slaves_freed)
          add_news!('EMANCIPATION',slaves_freed)
        end
      end
    end
  end

  def pay_wages!
    pay_troops!
    pay_workers!(Item::ARTISAN_WORKER,self.artisan_wages)
    pay_workers!(Item::FREEMEN_WORKER,self.freemen_wages)
    pay_workers!(Item::SLAVE_WORKER,self.slave_wages)

  end

  def add_item_to_queue!(item,quantity)
    self.production_queues.create!(:item => item, :quantity => quantity)
  end

  def alter_production_queue!(position,quantity)
    q = self.production_queues.find(:first, :conditions => {:position => position})
    return false unless q
    q.quantity = quantity
    q.save!
    q.quantity
  end

  def clear_production_queue!
    self.production_queues.each{|queue| queue.destroy}
  end

  def has_raw_materials(item)
    item.position_has_raw_materials_for(self)
  end

  def use_raw_materials(item,quantity=1)
    item.position_remove_raw_materials!(self,quantity)
  end

  def issue_delivery_authorisation!(noble_house)
    return unless Authorisation.issue_delivery!(self,noble_house)
    add_news!('ISSUE_AUTHORISATION',"to have items delivered by House #{noble_house.name}")
    noble_house.add_news!('RECEIVED_AUTHORISATION',"to deliver items to Estate #{self.name} in #{self.region.name}")
  end

  def issue_authorisation!(noble_house,item,quantity)
    return unless Authorisation.issue!(self,noble_house,item,quantity)
    add_news!('ISSUE_AUTHORISATION',"to pick up #{quantity} x #{item.name} to House #{noble_house.name}")
    noble_house.add_news!('RECEIVED_AUTHORISATION',"to pick up #{quantity} x #{item.name} from Estate #{self.name} in #{self.region.name}")
  end

  def revoke_authorisation!(noble_house,item=nil)
    if item
      auths = Authorisation.at(self).to(noble_house).of(item)
      return unless auths.size > 0
      auths.each do |auth| 
        quantity = auth.quantity
        add_news!('REVOKE_AUTHORISATION',"to pick up #{quantity} x #{item.name} to House #{noble_house.name}")
        noble_house.add_news!('AUTHORISATION_REVOKED',"to pick up #{quantity} x #{item.name} from Estate #{self.name} in #{self.region.name}")
        auth.destroy
      end
    else
      auths = Authorisation.at(self).to(noble_house).delivery
      return unless auths.size > 0
      auths.each do |auth| 
        add_news!('REVOKE_AUTHORISATION',"to have items delivered by House #{noble_house.name}")
        noble_house.add_news!('AUTHORISATION_REVOKED',"to deliver items to Estate #{self.name} in #{self.region.name}")
        auth.destroy
      end
    end
  end

  def total_taxpayers
    @total_taxpayers ||= worker_count(Item::FREEMEN_WORKER) + worker_count(Item::ARTISAN_WORKER)
  end

  def max_taxes
    @max_taxes ||= total_taxpayers * self.taxes
  end

  def total_slave_wages
    @total_slave_wages ||= self.slave_wages * worker_count(Item::SLAVE_WORKER)
  end

  def total_freemen_wages
    @total_freemen_wages ||= self.freemen_wages * worker_count(Item::FREEMEN_WORKER)
  end

  def total_artisan_wages
    @total_artisan_wages ||= self.artisan_wages * worker_count(Item::ARTISAN_WORKER)
  end

  def sum_wages
    @sum_wages ||= total_slave_wages + total_freemen_wages + total_artisan_wages
  end

  def total_production_capacity
    @total_production_capacity ||= Building.sum_production_capacity(self)
  end

  def total_shuttle_capacity
    @total_shuttle_capacity ||= Building.sum_shuttle_capacity(self)
  end

  def used_shuttle_capacity
    @total_shuttle_used ||= Building.sum_shuttle_capacity_used(self)
  end

  def available_shuttle_capacity
    total_shuttle_capacity - used_shuttle_capacity
  end

  def use_capacity!(usage, building_types, max_capacity_function)
    buildings = Building.at(self).of_types(building_types)
    total_used = 0
    buildings.each do |building|
      available = building.send(max_capacity_function) - building.capacity_used
      to_use = usage - total_used
      to_use = available if available < to_use
      building.update_attributes!(:capacity_used => building.capacity_used + to_use)
      total_used += to_use
      return total_used if total_used == usage
    end
    total_used
  end

  def use_shuttle_capacity!(usage)
    use_capacity!(usage, BuildingType.shuttles, :shuttle_capacity)
  end

  def use_production_capacity!(usage)
    use_capacity!(usage, BuildingType.production, :production_capacity)
  end

  def shuttle_to_estate!(estate,item,quantity)
    return false if estate.foreign_to?(self) && !Authorisation.has_delivery_rights?(estate, self.noble_house)
    qty_available = count_item(item)
    quantity = qty_available if qty_available < quantity
    qty_capacity = available_shuttle_capacity / item.mass if item.mass > 0
    qty_capacity = quantity unless qty_capacity
    quantity = qty_capacity if qty_capacity < quantity
    if quantity > 0
      transaction do
        transfer_items!(estate, item, quantity)
        use_shuttle_capacity!(item.mass * quantity)
        add_news!('SHUTTLE_ITEMS_TO',"#{item.name} x #{quantity} to Estate #{estate.name}")
        estate.add_news!('SHUTTLE_ITEMS_DELIVERED',"#{item.name} x #{quantity} from Estate #{self.name}")
      end
    else
      return false
    end
  end

  def shuttle_from_estate!(estate,item,quantity)
    return false if estate.foreign_to?(self) && !Authorisation.has_rights?(estate, self.noble_house,item)
    qty_available = estate.count_item(item)
    quantity = qty_available if qty_available < quantity
    if estate.foreign_to?(self)
      auth = Authorisation.rights_to(estate,self.noble_house,item)
      qty_authorised = auth.quantity
      quantity = qty_authorised if qty_authorised < quantity
    end
    qty_capacity = available_shuttle_capacity / item.mass if item.mass > 0
    qty_capacity = quantity unless qty_capacity
    quantity = qty_capacity if qty_capacity < quantity
    if quantity > 0
      transaction do
        auth.remove_item!(quantity) if auth
        estate.transfer_items!(self, item, quantity)
        use_shuttle_capacity!(item.mass * quantity)
        add_news!('SHUTTLE_ITEMS_FROM',"#{item.name} x #{quantity} from Estate #{estate.name}")
        estate.add_news!('SHUTTLE_ITEMS_TAKEN',"Estate #{self.name} picked up #{item.name} x #{quantity}")
      end
    else
      return false
    end
  end

  def shuttle_to_starship!(starship,item,quantity,install=false)
    return false if starship.nil? || starship.noble_house_id != self.noble_house_id
    return false unless starship.at_same_estate?(self) || starship.orbiting?(self.region.world)
    qty_available = count_item(item)
    quantity = qty_available if qty_available < quantity
    space_available = if install
      starship.space_to_install(item)
    else
      starship.space_available_for(item)
    end
    quantity = space_available if space_available < quantity
    unless starship.at_same_estate?(self)
      qty_capacity = available_shuttle_capacity / item.mass if item.mass > 0
      qty_capacity = quantity unless qty_capacity
      quantity = qty_capacity if qty_capacity < quantity
    end
    if quantity > 0
      transaction do
        if install
          starship.install!(item, quantity, false)
          remove_item!(item,quantity)
        else
          transfer_items!(starship, item, quantity)
        end
        use_shuttle_capacity!(item.mass * quantity) unless starship.at_same_estate?(self)
        and_installed = install ? " and installed " : ''
        add_news!('SHUTTLE_ITEMS_TO',"#{item.name} x #{quantity} to Starship #{starship.name}#{and_installed}")
        starship.add_news!('SHUTTLE_ITEMS_DELIVERED',"#{item.name} x #{quantity}#{and_installed} from Estate #{self.name}")
      end
    else
      return false
    end
  end

  def shuttle_from_starship!(starship,item,quantity,uninstall=false)
    return false if starship.nil? || starship.noble_house_id != self.noble_house_id
    return false unless starship.at_same_estate?(self) || starship.orbiting?(self.region.world)
    qty_available = if uninstall
      starship.count_section(item)
    else
      starship.count_item(item)
    end
    quantity = qty_available if qty_available < quantity
    unless starship.at_same_estate?(self)
      qty_capacity = available_shuttle_capacity / item.mass if item.mass > 0
      qty_capacity = quantity unless qty_capacity
      quantity = qty_capacity if qty_capacity < quantity
    end
    if quantity > 0
      transaction do
        if uninstall
          starship.uninstall!(item, quantity,false)
          add_item!(item,quantity)
        else
          starship.transfer_items!(self, item, quantity)
        end
        use_shuttle_capacity!(item.mass * quantity) unless starship.at_same_estate?(self)
        add_news!('SHUTTLE_ITEMS_FROM',"#{item.name} x #{quantity} from #{starship.name}")
        starship.add_news!('SHUTTLE_ITEMS_TAKEN',"Estate #{self.name} picked up #{item.name} x #{quantity}")
      end
    else
      return false
    end
  end

  def unique_name_per_region
    e = Estate.find_by_region_id_and_name(self.region_id, self.name)
    self.errors.add(:name, "must be unique per region") if e && e.id != self.id
  end

  def efficiency_for(building_type)
    base = @efficiency[building_type.worker_type]
    base += (effective_recruitment * 0.1) if building_type.recruitment?
    base += (effective_biogenics * 0.1) if building_type.trade_good?
    base += (effective_automation * 0.1) if building_type.ore?
    base += (self.noble_house.glory * 0.00001) if building_type.recruitment?
    base
  end

  def next_tournament
    return nil unless self.tournaments && self.tournaments.size > 0
    tournies = self.tournaments.select{|tournament| tournament.winner.nil? }.sort{|a,b| a.event_date <=> b.event_date}
    tournies.size > 0 ? tournies.first : nil
  end

  def holding_tournament?
    !next_tournament.nil?
  end

  private
  def calculate_efficiency
    [Item::SLAVE_WORKER,Item::FREEMEN_WORKER,Item::ARTISAN_WORKER].each do |worker_type|
      workers = worker_capacity(worker_type)
      morale = worker_morale(worker_type)
      if morale == 0
        @efficiency[worker_type] = 0
      else
        @efficiency[worker_type] = ((morale + workers + self.region.infrastructure_modifier) / 3.0) + (effective_management * 0.1)
      end
    end
  end

  def has_building_function?(function)
    unless @building_functions[function]
      self.buildings.each do |building|
        if building.building_type.send(function)
          @building_functions[function] = true
          return @building_functions[function]
        end
      end
    end
    @building_functions[function] || false
  end

  def pay_workers!(worker_type,wages)
    pop = population_type(worker_type)
    return if pop.nil? or pop.quantity < 1
    total = pop.quantity * wages
    total = self.noble_house.wealth unless self.noble_house.has_funds?(total)
    transaction do
      self.noble_house.subtract_wealth!(total)
      pop.add_wealth!(total)
      add_news!("PAY_WORKERS", "#{money(total)} to #{pop.quantity} of #{pop.category.pluralize_if(pop.quantity)}")
    end
  end

  def pay_troops!
    troop_bundles = bundles_of_type(Item::TROOP)
    transaction do
      troop_bundles.each do |ib|
        max_afford = self.noble_house.wealth
        if max_afford < ib.quantity
          max_afford = max_afford.to_i
          quantity_leave = ib.quantity - max_afford
          add_news!("TROOPS_LEAVE", "#{quantity_leave} of #{ib.item.name}")
          remove_item!(ib.item, quantity_leave)
          if max_afford > 0
            self.noble_house.subtract_wealth!(max_afford)
            add_news!("PAY_TROOPS", "#{money(ib.quantity)} to #{max_afford} of #{ib.item.name}")
          end
        else
          self.noble_house.subtract_wealth!(ib.quantity)
          add_news!("PAY_TROOPS", "#{money(ib.quantity)} to #{ib.quantity} of #{ib.item.name}")
        end
      end
    end
  end

  def reorder_production_queue!
    i = 0
    self.production_queue.each do |queue|
      queue.update_attributes!(:position => i)
      i += 1
    end
  end

  def destroy_empty_populations
    self.populations.each { |pop| pop.destroy_empty  }
  end

end
