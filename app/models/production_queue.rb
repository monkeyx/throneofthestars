class ProductionQueue < ActiveRecord::Base
  attr_accessible :estate, :item, :position, :quantity, :capacity_stored
  
  before_save   :check_position
  after_save    :destroy_empty

  belongs_to :estate
  belongs_to :item
  validates_numericality_of :position, :only_integer => true
  validates_numericality_of :quantity, :only_integer => true
  validates_numericality_of :capacity_stored, :only_integer => true

  def add_quantity!(quantity)
    update_attributes!(:quantity => self.quantity + quantity)
  end

  def subtract_quantity!(quantity)
    update_attributes!(:quantity => self.quantity - quantity)
  end

  def add_capacity!(quantity)
    update_attributes!(:capacity_stored => self.capacity_stored + quantity)
  end

  def subtract_capacity!(quantity)
    update_attributes!(:capacity_stored => self.capacity_stored - quantity)
  end

  def clear_capacity!
    subtract_capacity!(self.capacity_stored)
  end

  def check_position
    if self.position < 0
      self.position = self.estate.production_queues.size
    end
  end

  def destroy_empty
    destroy if self.quantity < 1
  end
end
