module OrderProcessing
  class DisembarkShipOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @starship ||= character.location

      return false if !@starship.location_estate? && fail!("Must be docked at an estate to disembark from a ship")
      true
    end

    def process!
      return false unless processable?
      @starship.disembark_character!(character)
    end

    def action_points
      2
    end

    def valid_for_character?
      character.location_starship? && character.location.location_estate?
    end
  end
end
