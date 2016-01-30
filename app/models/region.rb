class Region < ActiveRecord::Base
  attr_accessible :name, :hemisphere, :total_lands, :unclaimed_lands, :infrastructure, :last_tribute, :world, :church_funds, :alms, :education, :faith_projects, :earl, :bishop
  
  NORTHERN = "Northern"
  SOUTHERN = "Southern"

  SPRING = "Spring"
  SUMMER = "Summer"
  AUTUMN = "Autumn"
  WINTER = "Winter"

  NORTHERN_SEASONS = {World::ALPHA => SPRING, World::BETA => SUMMER, World::GAMMA => AUTUMN, World::DELTA => WINTER}
  SOUTHERN_SEASONS = {World::ALPHA => AUTUMN, World::BETA => WINTER, World::GAMMA => SPRING, World::DELTA => SUMMER}

  validates_presence_of :name
  validates_inclusion_of :hemisphere, :in => [NORTHERN,SOUTHERN]
  validates_numericality_of :total_lands, :only_integer => true
  validates_numericality_of :unclaimed_lands, :only_integer => true
  validates_numericality_of :infrastructure, :only_integer => true
  game_date :last_tribute
  belongs_to :world

  validates_numericality_of :church_funds
  validates_numericality_of :alms
  validates_numericality_of :education
  validates_numericality_of :faith_projects

  has_many :resources, :dependent => :destroy
  has_many :estates

  has_many :titles

  belongs_to :earl, :class_name => 'Character'
  belongs_to :bishop, :class_name => 'Character'

  scope :on, lambda {|world|
    {:conditions => {:world_id => world.id}}
  }

  scope :no_bishop, :conditions => 'bishop_id IS NULL OR bishop_id = 0'
  scope :has_bishop, :conditions => 'bishop_id IS NOT NULL AND bishop_id <> 0'

  scope :signup, :conditions => "unclaimed_lands > 100", :order => 'unclaimed_lands DESC'

  def self.cleanup_claimed_lands!
    Region.all.each{|r| r.adjust_unclaimed_lands! }
  end

  def adjust_unclaimed_lands!
    claimed_lands = self.estates.sum{|estate| estate.lands}
    unless claimed_lands == (total_lands - unclaimed_lands)
      self.unclaimed_lands = total_lands - claimed_lands
      Kernel.p "Region #{self.name} on #{self.world.name} adjusted unclaimed lands to #{self.unclaimed_lands}"
      save!
    end
  end
  
  def long_name
    @long_name ||= "#{self.world.name} - #{self.name}"
  end

  def current_season(quadrant=self.world.quadrant)
    if self.hemisphere == NORTHERN
      NORTHERN_SEASONS[quadrant]
    else
      SOUTHERN_SEASONS[quadrant]
    end
  end

  def next_rotation_season
    current_season(self.world.next_rotate_quadrant)
  end

  def season_trade_good_yield_modifier(season=current_season)
    case season
    when SPRING
      1.0
    when SUMMER
      0.5
    when AUTUMN
      -0.5
    when WINTER
      -1.0
    end
  end

  def season_birth_modifier
    current_season == SUMMER ? 1 : 0
  end

  def season_infant_death_modifier
    current_season == WINTER ? 2 : 0
  end

  def season_infant_illness_modifier
    current_season == WINTER ? 5 : 0
  end

  def season_infant_injury_modifier
    current_season == SUMMER ? 5 : 0
  end

  def season_ground_combat_allowed?
    current_season != WINTER
  end

  def add_resource!(item,yield_category)
    self.resources.create!(:item_id => item.id, :yield_category => yield_category)
  end

  def has_resource?(item)
    list = Resource.at(self).of(item)
    list.size > 0
  end

  def resource_yield_category(item)
    list = Resource.at(self).of(item)
    list.size > 0 ? list.first.yield_category : Resource::NONE
  end

  def current_resource_yield(item)
    list = Resource.at(self).of(item)
    list.size > 0 ? list.first.current_yield : 0
  end

  def next_rotation_resource_yield(item)
    list = Resource.at(self).of(item)
    list.size > 0 ? list.first.next_rotation_yield : 0
  end

  def max_resource_building_level(item)
    return 0 unless item
    list = Resource.at(self).of(item)
    list.size > 0 ? list.first.max_building_level : 0
  end

  def percentage_unclaimed
    return 0 if self.total_lands == 0
    ((self.unclaimed_lands.to_f / self.total_lands.to_f) * 100).to_i
  end

  def land_cost
    return 1000 if percentage_unclaimed > 95
    return 2000 if percentage_unclaimed > 89
    return 4000 if percentage_unclaimed > 69
    return 8000 if percentage_unclaimed > 49
    return 16000 if percentage_unclaimed > 24
    return 32000 if percentage_unclaimed > 10
    50000
  end

  def infrastructure_modifier
    1.0 + (self.infrastructure * 0.1)
  end

  def next_infrastructure_cost
    next_level = self.infrastructure + 1
    return (next_level * next_level * 10000)
  end

  def improve_infrastructure!
    update_attributes!(:infrastructure => self.infrastructure + 1)
  end

  def collect_tributes!
    # TODO collect tribues
  end

  def set_church_budget!(character, alms,education,faith_projects)
    return false unless character.bishop_of?(self)
    return false if (alms + education + faith_projects) != 100
    update_attributes!(:alms => alms, :education => education, :faith_projects => faith_projects)
    character.add_news!('CHURCH_BUDGET',"of #{self.name} to Alms #{alms}%, Education #{education}% and Faith Projects #{faith_projects}%")
  end

  def add_tithes!(tithes)
    update_attributes!(:church_funds => self.church_funds + tithes)
  end

  def distribute_church_funds!
    give_to_poor = (self.church_funds * (self.alms / 100.0)).to_i
    for_education = (self.church_funds * (self.education / 100.0)).to_i
    for_world = (self.church_funds * (self.faith_projects / 100.0)).to_i
    transaction do
      if give_to_poor > 0
        poor = Population.region(self).no_savings
        total_population = poor.sum{|pop| pop.quantity}.to_f
        unless total_population == 0
          alms_per_pop = (give_to_poor / total_population)
          poor.each do |pop|
            amount = (alms_per_pop * pop.quantity).round(0)
            pop.add_wealth!(amount)
            self.church_funds -= amount
          end
        end
      end
      if for_education > 0 && for_education >= next_infrastructure_cost
        self.church_funds -= next_infrastructure_cost
        improve_infrastructure!
      end
      if for_world > 0
        self.world.church_funds += for_world
        self.world.save!
        self.church_funds -= for_world
      end
      save!
    end
  end

  def add_ores!(rich_ores=[],poor_ores=[])
    # add ores
    Item.category(Item::ORE).each do |ore|
      yield_category = if rich_ores.include?(ore)
        Resource::RICH
      elsif poor_ores.include?(ore)
        Resource::POOR
      else
        Resource::NORMAL
      end
      add_resource!(ore, yield_category)
    end
  end

  def add_trade_goods!(rich_goods=[],poor_goods=[])
    Item.category(Item::TRADE_GOOD).source(self.world).each do |trade_good|
      yield_category = if rich_goods.include?(trade_good.trade_good_type)
        Resource::RICH
      elsif poor_goods.include?(trade_good.trade_good_type)
        Resource::POOR
      else
        Resource::NORMAL
      end
      add_resource!(trade_good, yield_category)
    end
  end
end

