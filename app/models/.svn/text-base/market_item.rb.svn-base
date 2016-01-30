class MarketItem < ActiveRecord::Base
  attr_accessible :noble_house, :item, :world, :quantity, :price, :listed_date
  
  after_save             :destroy_empty
  belongs_to :noble_house
  belongs_to :item
  belongs_to :world
  validates_numericality_of :quantity, :only_integer => true
  validates_numericality_of :price, :greater_than => 0
  game_date :listed_date

  scope :at, lambda {|world|
    {:conditions => {:world_id => world.id}, :include => :item}
  }

  scope :category, lambda {|category|
    {:conditions => ["item_id IN (?)",Item.category(category)]}
  }

  scope :of, lambda {|item|
    {:conditions => {:item_id => item.id}}
  }

  scope :of_items, lambda {|items|
    {:conditions => ["item_id IN (?)",items]}
  }

  scope :belongs_to, lambda {|noble_house|
    {:conditions => {:noble_house_id => noble_house.id}}
  }

  scope :does_not_belongs_to_a_noble_house, :conditions => "noble_house_id IS NULL"

  scope :price, lambda {|price|
    {:conditions => {:price => price}}
  }

  scope :order_by_price_asc, :order => 'price ASC'
  scope :order_by_item_name_then_price, :order => 'items.name ASC, price ASC'

  def self.market_stats(world)
    find_by_sql(["SELECT DISTINCT items.*,
                market_items.*,
                (SUM(market_items.price * market_items.quantity) / SUM(market_items.quantity)) AS avg_price,
                SUM(market_items.quantity) AS total_quantity,
                MAX(market_items.price) AS max_price,
                MIN(market_items.price) AS min_price
                FROM market_items, items
                WHERE market_items.item_id = items.id
                AND market_items.world_id = ?
                GROUP BY items.id
                ORDER BY items.name ASC", world.id])
  end

  def self.system_market_stats
    system_stats = {}
    World.all.each do |world|
      for market_item in find_by_sql(["SELECT DISTINCT items.*,
                  market_items.*,
                  (SUM(market_items.price * market_items.quantity) / SUM(market_items.quantity)) AS avg_price,
                  SUM(market_items.quantity) AS total_quantity
                  FROM market_items, items
                  WHERE market_items.item_id = items.id
                  AND market_items.world_id = ?
                  GROUP BY items.id
                  ORDER BY items.name ASC", world.id])
        ss_item = system_stats[market_item.item]
        ss_item = {} unless ss_item
        ss_item[world] = market_item
        system_stats[market_item.item] = ss_item
      end
    end
    system_stats
  end

  def self.sell_item!(position, world, item, quantity, price)
    # puts "Position = #{position.name} World = #{world.name} Item = #{item.name} Quantity = #{quantity} Price = #{price}"
    transaction do
      return 0 if item.immobile?
      if position.nil?
        list = at(world).of(item).price(price)
        mi = list.size > 0 ? list.first : new(:item => item, :price => price, :world => world, :quantity => 0)
      else
        list = at(world).of(item).price(price).belongs_to(position.noble_house)
        mi = list.size > 0 ? list.first : new(:noble_house => position.noble_house, :item => item, :price => price, :world => world, :quantity => 0)
        if item.worker? && position.is_a?(Estate)
          count = position.worker_count(item.worker_type)
        else
          count = position.count_item(item)
        end
        quantity = count if count < quantity
        if quantity > 0
          if position.is_a?(Estate) && item.worker?
            Population.subtract_population!(position, item.worker_type, quantity)
          else
            position.remove_item!(item, quantity)
          end
          position.add_news!("MARKET_SELL","#{quantity} x #{item.name.pluralize_if(quantity)}")
        end
      end
      mi.quantity += quantity
      mi.save!
      quantity
    end
  end

  def self.buy_item!(position, world, item, quantity, max_price)
    transaction do
      raise "Cannot buy a non-item" if item.nil?
      raise "No position specified" if position.nil?
      raise "No world specified" if world.nil?
      raise "No quantity specified" if quantity.nil?
      Timer.start_timer("buy_item")
      # Timer.start_timer("space_for")
      space_for = position.space_available_for(item)
      # Timer.puts_timer("space_for")
      # Timer.start_timer("shuttle_capacity")
      max_mass = position.respond_to?(:available_shuttle_capacity) ? position.available_shuttle_capacity : nil
      # Timer.puts_timer("shuttle_capacity")
      # Timer.start_timer("mass calculations")
      mass_for = max_mass.nil? ? nil : (max_mass / item.mass).to_i
      quantity = quantity > space_for ? space_for : quantity
      quantity = mass_for.nil? ? quantity : (quantity > mass_for ? mass_for : quantity)
      # Timer.puts_timer("mass calculations")
      # Timer.start_timer("find_items")
      list = at(world).of(item).order_by_price_asc
      # Timer.puts_timer("find_items")
      i = 0
      qty = 0
      while qty <= quantity && i < list.size && list[i].price <= max_price do
        mi = list[i]
        price = mi.price # save for later check
        #Timer.start_timer("MarketItem Buy #{mi.id}")
        qty += mi.buy!(position,(quantity - qty))
        #Timer.puts_timer("MarketItem Buy #{mi.id}")
        i += 1
        i = list.size unless position.has_funds?(price)
      end
      Timer.puts_timer("buy_item")
      qty
    end
  end

  def self.cancel_item!(position, world, item, price)
    transaction do
      list = at(world).of(item).belongs_to(position.noble_house).price(price)
      # puts "Found #{list.size} of #{item.name} at #{world.name} belonging to #{position.noble_house} of price #{price} to cancel"
      return 0 if list.size < 1
      list.first.cancel!(position)
    end
  end

  def buy!(position,qty)
    transaction do
      funds_for = position.funds_for(self.price)
      max_afford = qty > funds_for ? funds_for : qty
      max_avail = qty > self.quantity ? self.quantity : qty
      qty = qty > max_afford ? max_afford : qty
      qty = qty > max_avail ? max_avail : qty
      self.quantity -= qty
      if qty > 0 && position.respond_to?(:use_shuttle_capacity!)
        shuttle_use = qty * self.item.mass
        position.use_shuttle_capacity!(shuttle_use)
      end
      if self.item.worker? && position.respond_to?(:add_population!)
        position.add_population!(item.worker_type,qty)
      else
        position.add_item!(item, qty)
      end
      if qty > 0
        if position && position.respond_to?(:add_news!)
          unless position.noble_house_id == self.noble_house_id
            position.add_news!("MARKET_BUY","#{qty} x #{item.name.pluralize_if(qty)} at &pound;#{self.price} each")
          else
            position.add_news!("MARKET_RECALL", "#{qty} x #{item.name.pluralize_if(qty)}")
            save!
            return qty
          end
        end
        cost = qty * self.price
        unless self.noble_house.nil?
          position.transfer_funds!(self.noble_house,cost,"sale of #{qty} x #{item.name.pluralize_if(qty)} on #{self.world.name}")
        else
          position.subtract_wealth!(cost)
        end
      end
      save!
      qty
    end
  end

  def cancel!(position)
    transaction do
      space_for = position.space_available_for(self.item)
      qty = self.quantity > space_for ? space_for : self.quantity
      self.quantity -= qty
      if self.item.worker? && position.respond_to?(:add_population!)
        position.add_population!(item.worker_type,qty)
      else
        position.add_item!(item, qty)
      end
      position.add_news!("CANCEL_SALE", "#{qty} x #{self.item.name.pluralize_if(qty)}")
      save!
      qty
    end
  end

  def destroy_empty
    self.destroy if quantity < 1
  end

  def avg_price
    @avg_price ||= attributes['avg_price'].to_f
  end
  def min_price
    @min_price ||= attributes['min_price'].to_f
  end
  def max_price
    @max_price ||= attributes['max_price'].to_f
  end
  def total_quantity
    @total_quantity ||= attributes['total_quantity'].to_i
  end
end