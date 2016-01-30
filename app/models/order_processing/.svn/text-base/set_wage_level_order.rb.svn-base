module OrderProcessing
  class SetWageLevelOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Estate", OrderParameter::OWN_ESTATE,true)
      new_parameter("Slave Wages (&pound)", OrderParameter::NUMBER,true)
      new_parameter("Freemen Wages (&pound)", OrderParameter::NUMBER,true)
      new_parameter("Artisan Wages (&pound)", OrderParameter::NUMBER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!

      @estate ||= params[0].parameter_value_obj
      @slave_wages ||= params[1].parameter_value_obj.to_f
      @freemen_wages ||= params[2].parameter_value_obj.to_f
      @artisan_wages ||= params[3].parameter_value_obj.to_f

      return false if @slave_wages < 0 && fail!("Slave wages: Must be zero or higher")
      return false if @freemen_wages < 0 && fail!("Freemen wages: Must be zero or higher")
      return false if @artisan_wages < 0 && fail!("Artisan wages: Must be zero or higher")
      return false if (@estate.nil? || !@estate.same_house?(character)) && fail!("Not a valid estate")
      return false if @estate.noble_house.chancellor_id != character.id && fail!("Not chancellor of the house")
      true
    end

    def process!
      return false unless processable?
      @estate.set_wage_levels!(@slave_wages,@freemen_wages,@artisan_wages)
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
