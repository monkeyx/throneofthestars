module OrderProcessing
  class CommandShipOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @starship = character.location if character.location_starship?

      return false if !character.location_starship? && fail!("Must be onboard a ship")
      return false if !(@starship.captain.nil? || @starship.captain.same_location?(@starship)) && fail!("There is already a captain of SS #{@starship.name}")
      true
    end

    def process!
      return false unless processable?
      Title.appoint_captain!(character, @starship)
      @starship.captain_id == character.id
    end

    def action_points
      0
    end

    def valid_for_character?
      true
    end
  end
end
