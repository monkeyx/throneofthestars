class ItemBundle < ActiveRecord::Base
  attr_accessible :item, :quantity
  
  after_save             :destroy_empty

  def owner
    k = Kernel.const_get(self.owner_type)
    k.find(owner_id)
  end
  def owner=(o)
    self.owner_type = o.class.to_s
    self.owner_id = o.id
  end
  belongs_to :item
  validates_numericality_of :quantity, :only_integer => 0

  scope :at, lambda {|owner|
    {:conditions => {:owner_type => owner.class.to_s, :owner_id => owner.id}}
  }

  scope :of, lambda {|item|
    {:conditions => {:item_id => item.id}}
  }

  scope :of_type, lambda {|item_category|
    {:conditions => ["item_id IN (?)", Item.category(item_category)]}
  }

  scope :types, lambda {|item_categories|
    {:conditions => ["item_id IN (?)", Item.categories(item_categories)]}
  }

  def self.add_item!(owner,item,quantity)
    list = at(owner).of(item)
    if list.size < 1
      ib = create_bundle!(owner,item,quantity)
    else
      ib = list.first
      ib.update_attributes!(:quantity => ib.quantity + quantity)
    end
    ib
  end

  def self.subtract_item!(owner,item,quantity)
    list = at(owner).of(item)
    q = 0
    if list.size > 0
      ib = list.first
      q = ib.quantity < quantity ? ib.quantity : quantity
      ib.update_attributes(:quantity => ib.quantity - quantity)
    end
    ib
  end
  
  def self.count_items(owner,item)
    ib = at(owner).of(item)
    ib.size > 0 ? ib.first.quantity : 0
  end

  def +(quantity)
    self.quantity += quantity
  end

  def -(quantity)
    self.quantity -= quantity
  end

  def total_mass
    self.item.mass * self.quantity
  end

  def destroy_empty
    self.destroy if quantity < 1
  end

  private
  def self.create_bundle!(owner,item,quantity)
    ib = ItemBundle.new(:item => item, :quantity => quantity)
    ib.owner = owner
    ib.save!
    ib
  end
end
