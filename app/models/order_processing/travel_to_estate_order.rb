module OrderProcessing
  class TravelToEstateOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Estate", OrderParameter::WORLD_ESTATE,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @estate ||= params[0].parameter_value_obj

      return false if character.at_same_estate?(@estate) && fail!("Already at estate")
      true
    end

    def process!
      return false unless processable?
      character.move_to_estate!(@estate)
    end

    def action_points
      4
    end

    def valid_for_character?
      true
    end
  end
end
