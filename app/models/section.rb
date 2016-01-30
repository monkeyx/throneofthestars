class Section < ActiveRecord::Base
  attr_accessible :starship, :item, :quantity

  belongs_to :starship
  belongs_to :item

  validates_numericality_of :quantity, :only_integer => true

  scope :on, lambda {|starship|
    {:conditions => {:starship_id => starship.id}}
  }

  scope :of, lambda {|item|
    {:conditions => {:item_id => item.id}}
  }

  scope :of_type, lambda {|section_type|
    {:conditions => ["item_id IN (?)", Item.category(section_type)]}
  }

  scope :from_types, lambda {|section_types|
    {:conditions => ["item_id IN (?)", Item.categories(section_types)]}
  }

end
