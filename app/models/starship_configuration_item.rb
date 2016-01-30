class StarshipConfigurationItem < ActiveRecord::Base
  attr_accessible :starship_configuration, :item, :starship_configuration_id, :item_id, :quantity

  belongs_to :starship_configuration
  belongs_to :item
  validates_numericality_of :quantity, :only_integer => true
end
