module OrderProcessing
  class EmbarkShipOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Starship", OrderParameter::OWN_STARSHIP,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @starship ||= params[0].parameter_value_obj

      return false if !(@starship.at_same_estate?(character) || @starship.orbiting?(character.current_world)) && fail!("Ship must be at same estate or in orbit of the same world to be boarded")
      return false if @starship.debris? && fail!("Cannot board a debris field")
      true
    end

    def process!
      return false unless processable?
      @starship.embark_character!(character)
    end

    def action_points
      2
    end

    def valid_for_character?
      character.current_estate
    end
  end
end
