module OrderProcessing
  class AppointEmissaryOrder < BaronOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Character", OrderParameter::OWN_CHARACTER,true)
    end

    def processable?
      return false unless super
      
      @character ||= params[0].parameter_value_obj

      return false if (!@character.location_estate? || !@character.location_foreign?) && fail!("Not at a foreign estate")
      return false if @character.prisoner && fail!("Cannot appoint prisoners")
      return false if !@character.adult? && fail!("Character must be an adult")
      return false if @character.id == character.id && fail!("Character cannot be self")
      true
    end

    def process!
      return false unless processable?
      Title.appoint_emissary!(@character, @character.location)
    end

    def action_points
      1
    end

  end
end
