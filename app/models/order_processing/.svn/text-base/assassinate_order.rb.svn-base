module OrderProcessing
  class AssassinateOrder < EmissaryOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Target", OrderParameter::CHARACTER_ESTATE, true)
    end

    def processable?
      return false unless super

      @target ||= params[0].parameter_value_obj

      return false unless @target.at_same_estate?(character) && fail!("Target is not at the same estate")
      true
    end

    def process!
      return false unless processable?
      character.assassinate!(@target)
    end

    def action_points
      4
    end

  end
end
