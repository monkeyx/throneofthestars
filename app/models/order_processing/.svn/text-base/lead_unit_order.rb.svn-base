module OrderProcessing
  class LeadUnitOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Army", OrderParameter::OWN_ARMY,true)
      new_parameter("Unit", OrderParameter::UNIT,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @army ||= params[0].parameter_value_obj
      @unit ||= params[1].parameter_value_obj

      return false if !character.same_house?(character) && fail!("Army must be of own house")
      return false if @unit.knight && fail!("Unit already led by a knight")
      return false if !@army.at_same_estate?(character) && fail!("Not at same estate")
      return false if !character.knight? && fail!("Only knights can lead units")
      true
    end

    def process!
      return false unless processable?
      @unit.assign_knight!(character)
    end

    def action_points
      1
    end

    def valid_for_character?
      character.knight? && character.current_estate
    end
  end
end
