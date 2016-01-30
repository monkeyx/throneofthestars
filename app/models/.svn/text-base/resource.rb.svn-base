class Resource < ActiveRecord::Base
  attr_accessible :region_id, :item_id, :yield_category

  NONE = "None"
  RICH = "Rich"
  NORMAL = "Normal"
  POOR = "Poor"

  belongs_to :region
  belongs_to :item
  validates_inclusion_of :yield_category, :in => [RICH,NORMAL,POOR]

  scope :at, lambda {|region|
    {:conditions => {:region_id => region.id}}
  }

  scope :of, lambda {|item|
    {:conditions => {:item_id => item.id}}
  }

  scope :yield_category, lambda {|yield_category|
    {:conditions => {:yield_category => yield_category}}
  }

  def resource_yield(season_modifier=self.region.season_trade_good_yield_modifier)
    mod = item.trade_good? ? (1.0 + season_modifier) : 1.0
    (self.item.yield_value(self.yield_category) * mod).round(0).to_i
  end

  def current_yield
    resource_yield(self.region.season_trade_good_yield_modifier)
  end

  def next_rotation_yield
    resource_yield(self.region.season_trade_good_yield_modifier(self.region.next_rotation_season))
  end

  def max_building_level
    case yield_category
    when RICH
      100
    when NORMAL
      50
    when POOR
      20
    else
      0
    end
  end

  def building_type
    return nil unless self.item
    list = if self.item.trade_good?
      BuildingType.trade_good_type(self.item.trade_good_type)
    else
      BuildingType.item_produced(self.item)
    end
    list.size > 0 ? list.first : nil
  end
end
