module OrderProcessing
  class ExecutePrisonerOrder < LordOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Character", OrderParameter::PRISONER_ESTATE,true)
    end

    def processable?
      return false unless super
      
      @prisoner ||= params[0].parameter_value_obj

      return false if @prisoner.prisoner.nil? && fail!("Not a prisoner")
      true
    end

    def process!
      return false unless processable?
      @prisoner.prisoner.execute!
    end

    def action_points
      2
    end
  end
end
