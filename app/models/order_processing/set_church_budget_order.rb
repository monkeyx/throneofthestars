module OrderProcessing
  class SetChurchBudgetOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Alms (%)", OrderParameter::NUMBER,true)
      new_parameter("Education (%)", OrderParameter::NUMBER,true)
      new_parameter("Faith Project (%)", OrderParameter::NUMBER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!

      @alms ||= params[0].parameter_value_obj.to_i
      @education ||= params[1].parameter_value_obj.to_i
      @faith ||= params[2].parameter_value_obj.to_i
      @region ||= Title.belonging_to(character).title(Title::BISHOP).first.region

      return false if (@alms < 0 || @alms > 100) && fail!("Alms must be a percentage between 0% and 100%")
      return false if (@education < 0 || @education > 100) && fail!("Education must be a percentage between 0% and 100%")
      return false if (@faith < 0 || @faith > 100) && fail!("Faith Projects must be a percentage between 0% and 100%")
      return false if (@alms + @education + @faith) != 100 && fail!("Total budget for church must equal 100%")
      true
    end

    def process!
      return false unless processable?
      @region.set_church_budget!(character, @alms,@education,@faith)
    end

    def action_points
      4
    end

    def valid_for_character?
      character.bishop?
    end
  end
end
