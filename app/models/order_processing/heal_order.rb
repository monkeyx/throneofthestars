module OrderProcessing
  class HealOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Character", OrderParameter::OWN_CHARACTER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @character ||= params[0].parameter_value_obj

      return false if !character.doctor? && fail!("Must have medical skill")
      return false if !@character.can_be_healed? && fail!("Character cannot be healed")
      return false if !character.same_location?(@character) && fail!("Must be at same location to be healed")
      true
    end

    def process!
      return false unless processable?
      character.heal!(@character)
    end

    def action_points
      4
    end

    def action_points_on_fail
      4
    end

    def valid_for_character?
      character.doctor?
    end
  end
end
