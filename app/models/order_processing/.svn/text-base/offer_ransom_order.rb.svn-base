module OrderProcessing
  class OfferRansomOrder < BaronOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Character", OrderParameter::PRISONER_HOUSE,true)
      new_parameter("Ransom &pound;", OrderParameter::NUMBER, true)
    end

    def processable?
      return false unless super
      
      @prisoner ||= params[0].parameter_value_obj
      @ransom ||= params[1].parameter_value_obj.to_f

      return false if @prisoner.prisoner.nil? && fail!("Character must be a prisoner")
      return false if @prisoner.current_estate.nil? && fail!("Prisoner must be at an estate")
      return false if @prisoner.current_estate.lord.nil? && fail!("Prisoner must be at an estate with a serving Lord")
      return false if @ransom > character.noble_house.wealth && fail!("Insufficient funds for the ransom")
      true
    end

    def process!
      return false unless processable?
      Ransom.ransom!(character,@prisoner.prisoner,@ransom)
    end

    def action_points
      2
    end
  end
end
