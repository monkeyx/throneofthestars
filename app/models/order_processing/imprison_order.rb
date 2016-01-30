module OrderProcessing
  class ImprisonOrder < LordOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Character", OrderParameter::CHARACTER_ESTATE,true)
    end

    def processable?
      return false unless super
      
      @character ||= params[0].parameter_value_obj

      return false if !@character.at_same_estate?(@estate) && fail!("Character must be at estate")
      return false if @character.id == character.id && fail!("Character cannot be self")
      true
    end

    def process!
      return false unless processable?
      Prisoner.imprison!(@character,@estate,false)
    end

    def action_points
      2
    end
  end
end
