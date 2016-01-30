class World < ActiveRecord::Base
  attr_accessible :name,:distance, :quadrant, :rotation, :last_imperial_tribute, :last_rotation, :last_tribute, :church_funds, :duke_id, :archbishop_id
  ALPHA = 1
  BETA = 2
  GAMMA = 3
  DELTA = 4
  QUADRANTS = [ALPHA, BETA, GAMMA, DELTA]
  QUADRANT_NAMES = {ALPHA => "Alpha", BETA => "Beta", GAMMA => "Gamma", DELTA => "Delta"}

  QUAD_DISTANCE = {
    ALPHA => {ALPHA => 0, BETA => 1, GAMMA => 2, DELTA => 1},
    BETA => {ALPHA => 1, BETA => 0, GAMMA => 1, DELTA => 2},
    GAMMA => {ALPHA => 2, BETA => 1, GAMMA => 0, DELTA => 1},
    DELTA => {ALPHA => 1, BETA => 2, GAMMA => 1, DELTA => 0}
  }

  MAP_ORIGIN = 9
  MAP_WIDTH = MAP_ORIGIN * 2
  MAP_HEIGHT = MAP_ORIGIN * 2 
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :distance, :only_integer => true
  validates_inclusion_of :quadrant, :in => QUADRANTS
  validates_numericality_of :rotation, :only_integer => true
  game_date :last_rotation
  game_date :last_imperial_tribute
  game_date :last_tribute

  validates_numericality_of :church_funds

  has_many :world_projects, :dependent => :destroy
  has_many :regions, :dependent => :destroy

  has_many :market_items, :dependent => :destroy

  has_many :titles, :dependent => :destroy

  belongs_to :duke, :class_name => 'Character'
  belongs_to :archbishop, :class_name => 'Character'

  scope :no_archbishop, :conditions => 'archbishop_id IS NULL OR archbishop_id = 0'

  def self.quad_distance(a,b)
    QUAD_DISTANCE[a.quadrant][b.quadrant]
  end

  def self.map
    rows = {MAP_ORIGIN => {MAP_ORIGIN => ['Sun']}}
    all.each do |world|
      x,y = world.map_position
      row = rows[y]
      row = {} unless row
      if row[x]
        row[x] << world
      else
        row[x] = [world]
      end
      rows[y] = row
    end
    rows
  end

  def self.create_world!(name, distance=1, rotation=1, quadrant=QUADRANTS.sample)
    world = create!(:name => name, :distance => distance, :quadrant => quadrant, :rotation => rotation, :last_rotation => Game.current_date)
    world.create_trade_goods!
    world.create_workers!
    world
  end

  def map_position
    return @x, @y if @x && @y
    @x, @y = calculate_position(self.quadrant)
    if ratio_rotated_in_quadrant > 0
      next_quadrant = self.quadrant + 1
      next_quadrant = ALPHA if next_quadrant > DELTA
      x2, y2 = calculate_position(next_quadrant)
      dx = (x2 - @x)
      dy = (y2 - @y)
      rx = (dx * ratio_rotated_in_quadrant)
      ry = (dy * ratio_rotated_in_quadrant)
      @x = @x + rx
      @y = @y + ry
    end
    @x = @x.round(0).to_i
    @y = @y.round(0).to_i
    return @x, @y
  end

  def calculate_position(quadrant)
    dmod = (self.distance / 3.0)
    case quadrant
    when ALPHA
      x = MAP_ORIGIN + dmod 
      y = MAP_ORIGIN + dmod
    when BETA
      x = MAP_ORIGIN + dmod
      y = MAP_ORIGIN - dmod
    when GAMMA
      x = MAP_ORIGIN - dmod
      y = MAP_ORIGIN - dmod
    when DELTA
      x = MAP_ORIGIN - dmod
      y = MAP_ORIGIN + dmod
    end
    return x, y
  end

  def has_project?(category)
    self.world_projects.count(:conditions => {:category => category}) > 0
  end

  def build_project!(category)
    WorldProject.build_project!(self, category)
  end

  def position_description
    @position_description ||= "#{self.quadrant_name} #{self.distance} #{rotation_description}".strip
  end

  def rotation_description
    @rotation_description ||= "(#{(ratio_rotated_in_quadrant * 100).round(0).to_i}% to #{quadrant_name(next_quadrant)})" if ratio_rotated_in_quadrant >= 0.1
  end

  def ratio_rotated_in_quadrant
    @ratio_rotated_in_quadrant ||= (chronum_since_last_rotation / self.rotation.to_f)
  end

  def chronum_since_last_rotation
    @chronum_since_last_rotation ||= Game.current_date.difference(self.last_rotation)
  end
  
  def rotate!
    return unless self.last_rotation.nil? ||  chronum_since_last_rotation >= self.rotation
    self.quadrant += 1
    self.quadrant = ALPHA if self.quadrant > DELTA
    self.last_rotation = Game.current_date
    save!
    self.quadrant
  end

  def next_quadrant
    return @next_quadrant if @next_quadrant
    @next_quadrant = self.quadrant + 1
    @next_quadrant = ALPHA if @next_quadrant > DELTA
    @next_quadrant
  end

  def next_rotate_quadrant
    @next_rotate_quadrant ||= if Game.current_date.difference(self.last_rotation) + 1 >= self.rotation
      next_quadrant
    else
      self.quadrant
    end
  end

  def quadrant_name(quadrant=self.quadrant)
    QUADRANT_NAMES[quadrant]
  end

  def quadrant_letter(quadrant=self.quadrant)
    quadrant_name(quadrant=self.quadrant)[0]
  end

  def add_region!(name,hemisphere,total_lands,rich_ores=[],poor_ores=[],rich_goods=[],poor_goods=[])
    region = self.regions.create!(:name => name, :hemisphere => hemisphere, :total_lands => total_lands, :unclaimed_lands => total_lands)
    region.add_ores!(rich_ores, poor_ores)
    region.add_trade_goods!(rich_goods, poor_goods)
    region
  end

  def collect_tributes!
    # TODO collect tribues
  end

  def collect_imperial_tax!
    # TODO collect imperial tax
  end

  def total_lands
    self.regions.to_a.sum{|region| region.total_lands}
  end

  def total_unclaimed_lands
    self.regions.to_a.sum{|region| region.unclaimed_lands}
  end

  def create_trade_goods!
    Item::TRADE_GOOD_TYPES.each do |trade_good_type|
      unless trade_good_type == Item::NONE
        Item.create_trade_good!(trade_good_type, self)
      end
    end
  end

  def create_workers!
    Item::WORKER_TYPES.each do |worker_type|
      unless worker_type == Item::NONE
        Item.create_worker!(worker_type, self)
      end
    end
  end
  
  def seed_market!
    lands = total_lands
    Item.source(self).category(Item::WORKER).each do |item|
      case item.worker_type
      when Item::SLAVE_WORKER
        quantity = lands
        price = 1
      when Item::FREEMEN_WORKER
        quantity = lands / 10
        price = 10
      when Item::ARTISAN_WORKER
        quantity = lands / 100
        price = 100
      end
      MarketItem.sell_item!(nil, self, item, quantity, price)
    end
    Item.category(Item::MODULE).each do |item|
      quantity = lands / item.mass
      price = item.mass * 5
      MarketItem.sell_item!(nil, self, item, quantity, price)
    end
  end

  def estates
    return @estates if @estates
    @estates = []
    self.regions.each{|region| @estates = @estates + region.estates.to_a }
    @estates
  end
end
