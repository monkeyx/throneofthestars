class Population < ActiveRecord::Base
  attr_accessible :estate, :category, :quantity, :morale, :wealth
  
  MORALE_PENALTY = 0.2

  after_save  :estate_set_totals
  belongs_to :estate
  validates_inclusion_of :category, :in => Item::WORKER_TYPES
  validates_numericality_of :quantity, :only_integer => true
  validates_numericality_of :morale
  validates_numericality_of :wealth

  include Wealthy
  include ItemContainer

  def estate_set_totals
    self.estate.set_totals if self.estate
  end

  def dummy_container?
    true
  end

  scope :at, lambda {|estate|
    {:conditions => {:estate_id => estate.id}}
  }

  scope :region, lambda {|region|
    {:conditions => ["estate_id IN (?)", region.estates]}
  }

  scope :category, lambda {|category|
    {:conditions => {:category => category}}
  }

  scope :no_savings, :conditions => {:wealth => 0}

  def self.world_census(world)
    find_by_sql(["SELECT DISTINCT populations.category AS category,
                  SUM(quantity) AS total_quantity,
                  SUM(morale * quantity) AS total_morale,
                  SUM(wealth * quantity) AS total_wealth,
                  SUM(wealth * quantity) / SUM(quantity) AS avg_wealth,
                  SUM(morale * quantity) / SUM(quantity) AS avg_morale
                  FROM populations
                  WHERE populations.estate_id IN (?)
            		  GROUP BY category
                  ORDER BY category ASC", Estate.on(world)])
  end

  def self.region_census(region)
    find_by_sql(["SELECT DISTINCT populations.category AS category,
                  SUM(quantity) AS total_quantity,
                  SUM(morale * quantity) AS total_morale,
                  SUM(wealth * quantity) AS total_wealth,
                  SUM(wealth * quantity) / SUM(quantity) AS avg_wealth,
                  SUM(morale * quantity) / SUM(quantity) AS avg_morale
                  FROM populations
                  WHERE populations.estate_id IN (?)
            		  GROUP BY category
                  ORDER BY category ASC", Estate.at(region)])
  end

  def self.count_population(estate, category)
    pop = estate.populations.find(:first, :conditions => {:category => category})
    pop.nil? ? 0 : pop.quantity
  end

  def self.update_population(estate,category,quantity)
    pop = find_or_create_by_estate_id_and_category(estate.id, category)
    if quantity < 1
      pop.destroy
    else
      pop.update_attributes!(:quantity => quantity)
    end
    pop
  end

  def self.add_population!(estate, category, quantity)
    update_population(estate,category,count_population(estate, category) + quantity)
  end

  def self.subtract_population!(estate, category, quantity)
    update_population(estate,category,count_population(estate, category) - quantity)
  end

  def self.transfer_population!(estate, from_category, to_category, quantity)
    subtract_population!(estate,from_category,quantity)
    add_population!(estate,to_category,quantity)
  end

  def self.load_population!(estate, starship, category, quantity)
    max = count_population(estate,category)
    quantity = max if quantity > max
    item = Item.worker(category).source(estate.region.world).first
    max = starship.space_available(item.category) / item.mass
    quantity = max if quantity > max
    transaction do
      starship.add_item!(item,quantity)
      subtract_population!(estate, category, quantity)
    end
    quantity
  end

  def self.unload_population!(estate, starship, item, quantity)
    max = starship.count_item(item)
    quantity = max if quantity > max
    transaction do
      starship.remove_item!(item,quantity)
      add_population!(estate, item.worker_type, quantity)
    end
    quantity
  end

  def pay_taxes!(tax_level=self.estate.taxes)
    total = tax_level * self.quantity
    case self.category
    when Item::ARTISAN_WORKER
      total = self.wealth unless has_funds?(total)
    when Item::FREEMEN_WORKER
      unless has_funds?(total)
        # enslavement of tax dodgers
        # TODO check for edict of emancipation
        enslaved = (self.quantity - funds_for(tax_level)).to_f.round(0).to_i
        total = tax_level * (self.quantity - enslaved)
        Population.transfer_population!(self.estate,self.category,Item::SLAVE_WORKER,enslaved)
        self.quantity -= enslaved
        self.estate.add_news!("ENSLAVED", "#{enslaved} people for tax evasion")
      end
    else #slaves don't pay taxes
      total = 0
    end
    if total > 0
      subtract_wealth!(total)
      self.estate.add_wealth!(total)
      self.estate.add_news!("TAXES_PAID", "#{money(total)} paid by #{self.quantity} x #{self.category}")
    end
    total
  end

  def buy_needs!
    self.morale = 1.0
    base_needs = population_needs(self.estate.region.current_season)
    base_needs.each do |need|
      total_needs = need[1]
      total_needs_met = 0
      i = 0
      list = market_items_by_need(need[0])
      list_size = list.size
      while total_needs_met < total_needs && i < list_size do
        mi = list[i]
        price = mi.price # save for later check incase the marketitem object disappears
        qty_needed = (total_needs - total_needs_met)
        qty_bought = mi.buy!(self, qty_needed)
        #Kernel.p "#{self.quantity} x #{self.category} at #{self.estate.name} bought #{qty_bought} x #{mi.item.name} at #{price}"
        total_needs_met += qty_bought
        i += 1
        i = list_size unless has_funds?(price)
      end
      if total_needs_met < total_needs
        factor = (total_needs_met.to_f / total_needs.to_f)
        self.morale -= (MORALE_PENALTY * (1.0 - (factor * factor)))
      end
    end
    if self.morale < 1.0
      self.wealth -= ((1.0 - self.morale) * self.wealth)
    end
    save!
  end

  def destroy_empty
    self.destroy if quantity < 1
  end

  def population_needs(season)
    needs = []
    needs << [:food, self.quantity]
    case self.category
      when Item::SLAVE_WORKER
        needs << [:drink, self.quantity]
      when Item::FREEMEN_WORKER
        needs << [:meat, self.quantity]
        needs << [:beer, self.quantity]
      when Item::ARTISAN_WORKER
        needs << [:meat, self.quantity]
        needs << [:fish, self.quantity]
        needs << [:wine, self.quantity]
    end
    case season
      when Region::SPRING
        case self.category
          when Item::ARTISAN_WORKER
            needs << [:clothing, self.quantity]
        end
      when Region::SUMMER
        case self.category
          when Item::FREEMEN_WORKER
            needs << [:clothing, self.quantity]
          when Item::ARTISAN_WORKER
            needs << [:silk, self.quantity]
        end
      when Region::AUTUMN
        case self.category
          when Item::ARTISAN_WORKER
            needs << [:silk, self.quantity]
        end
      when Region::WINTER
        needs << [:clothing, self.quantity]
    end
    needs
  end

  def market_items_by_need(need_type)
    world = self.estate.region.world
    return case need_type
    when :food
      MarketItem.at(world).of_items(Item.food).order_by_price_asc
    when :drink
      MarketItem.at(world).of_items(Item.drink).order_by_price_asc
    when :clothing
      MarketItem.at(world).of_items(Item.clothing).order_by_price_asc
    when :meat
      MarketItem.at(world).of_items(Item.trade_good(Item::FOOD_MEAT)).order_by_price_asc
    when :fish
      MarketItem.at(world).of_items(Item.trade_good(Item::FOOD_FISH)).order_by_price_asc
    when :beer
      MarketItem.at(world).of_items(Item.trade_good(Item::DRINK_BEER)).order_by_price_asc
    when :wine
      MarketItem.at(world).of_items(Item.trade_good(Item::DRINK_WINE)).order_by_price_asc
    when :silk
      MarketItem.at(world).of_items(Item.trade_good(Item::CLOTHING_SILK)).order_by_price_asc
    end
  end

  def total_quantity
    attributes['total_quantity'].to_i
  end
  def avg_wealth
    attributes['avg_wealth'].to_f.round(2)
  end
  def avg_morale
    attributes['avg_morale'].to_f.round(2)
  end
end
