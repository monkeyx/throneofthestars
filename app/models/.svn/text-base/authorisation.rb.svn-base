class Authorisation < ActiveRecord::Base
  attr_accessible :estate, :noble_house, :item, :quantity, :issued_date, :delivery
  
  belongs_to :estate
  belongs_to :noble_house
  belongs_to :item
  validates_numericality_of :quantity, :only_integer => true
  game_date :issued_date
  # delivery

  after_save :destroy_used

  scope :at, lambda {|estate|
    {:conditions => {:estate_id => estate.id}}
  }

  scope :to, lambda {|noble_house|
    {:conditions => {:noble_house_id => noble_house.id}}
  }

  scope :of, lambda {|item|
    {:conditions => {:item_id => item.id}}
  }

  scope :delivery, :conditions => {:delivery => true}

  def self.has_rights?(estate,noble_house,item)
    at(estate).to(noble_house).of(item).size > 0
  end

  def self.rights_to(estate,noble_house,item)
    at(estate).to(noble_house).of(item).first
  end

  def self.has_delivery_rights?(estate,noble_house)
    at(estate).to(noble_house).delivery.size > 0
  end

  def self.issue!(estate,noble_house,item,quantity)
    auth = find_by_estate_id_and_noble_house_id_and_item_id(estate.id, noble_house.id, item.id)
    unless auth
      auth = create!(:estate => estate, :noble_house => noble_house, :item => item, :quantity => quantity)
    else
      auth.update_attributes!(:quantity => (auth.quantity + quantity))  
    end
    auth
  end

  def self.issue_delivery!(estate,noble_house)
    find_or_create_by_estate_id_and_noble_house_id_and_delivery(estate.id, noble_house.id, true)
  end

  def self.pickup!(estate,starship,item,quantity)
    list = at(estate).to(starship.noble_house).of(item)
    return 0 if list.size < 1
    auth = list.first
    quantity = auth.quantity if quantity > auth.quantity
    space_for = starship.space_available(item.category)
    quantity = space_for if quantity > space_for
    return 0 unless quantity > 0
    transaction do
      starship.add_item!(item,quantity)
      auth.remove_item!(quantity)
    end
    starship.add_news!('SHIP_LOAD_CARGO', "#{quantity} x #{item.name} from Estate #{estate.name}")
    quantity
  end

  def add_item!(quantity)
    update_attributes!(:quantity => self.quantity + quantity)
  end

  def remove_item!(quantity)
    quantity = self.quantity if quantity > self.quantity
    update_attributes!(:quantity => self.quantity - quantity)
    quantity
  end

  def destroy_used
    unless self.delivery?
      destroy if self.quantity == 0
    end 
  end
end
