module OrderProcessing
  class SpyOrder < EmissaryOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Information Type", OrderParameter::INFORMATION_TYPE, true)
    end

    def processable?
      return false unless super

      @information_type ||= params[0].parameter_value_obj

      true
    end

    def process!
      return false unless processable?
      character.spy!(@information_type)
    end

    def action_points
      4
    end

  end
end
