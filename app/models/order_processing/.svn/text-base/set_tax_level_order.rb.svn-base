module OrderProcessing
  class SetTaxLevelOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Estate", OrderParameter::OWN_ESTATE,true)
      new_parameter("Tax Level (&pound)", OrderParameter::NUMBER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!

      @estate ||= params[0].parameter_value_obj
      @tax_level ||= params[1].parameter_value_obj.to_f

      return false if @tax_level < 0 && fail!("Must be zero or higher")
      return false if (@estate.nil? || !@estate.same_house?(character)) && fail!("Not a valid estate")
      return false if @estate.noble_house.chancellor_id != character.id && fail!("Not chancellor of the house")
      true
    end

    def process!
      return false unless processable?
      @estate.set_tax_level!(@tax_level)
      true
    end

    def action_points
      4
    end

    def valid_for_character?
      character.chancellor?
    end
  end
end
