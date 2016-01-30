module OrderProcessing
  class LeadArmyOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Army", OrderParameter::OWN_ARMY,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @army ||= params[0].parameter_value_obj

      return false if !character.same_house?(character) && fail!("Army must be of own house")
      return false if @army.legate && fail!("Army already has legate")
      return false if !@army.at_same_estate?(character) && fail!("Not at same estate")
      return false if !character.adult_male? && fail!("Only adult males can lead armies")
      true
    end

    def process!
      return false unless processable?
      Title.appoint_legate!(character, @army)
    end

    def action_points
      1
    end

    def valid_for_character?
      character.adult_male? && character.current_estate
    end
  end
end
