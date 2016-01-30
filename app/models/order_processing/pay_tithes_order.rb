module OrderProcessing
  class PayTithesOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Tithe", OrderParameter::NUMBER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!

      @amount ||= params[0].parameter_value_obj.to_i
      @estate ||= character.current_estate

      return false if (!@estate || !@estate.tithe_allowed?) && fail!("Must be at an estate with a chapel to pay tithes")
      true
    end

    def process!
      return false unless processable?
      character.pay_tithes!(@amount)
    end

    def action_points
      2
    end

    def valid_for_character?
      character.lord? || character.deacon? || character.bishop?
    end
  end
end
