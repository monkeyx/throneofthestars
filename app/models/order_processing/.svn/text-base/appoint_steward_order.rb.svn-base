module OrderProcessing
  class AppointStewardOrder < LordOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Estate", OrderParameter::OWN_ESTATE,true)
      new_parameter("Character", OrderParameter::OWN_CHARACTER,true)
    end

    def processable?
      return false unless super
      
      @character ||= params[1].parameter_value_obj

      return false if !@character.at_same_estate?(@estate) && fail!("Character must be at estate")
      return false if !@character.adult? && fail!("Character must be an adult")
      return false if @character.id == character.id && fail!("Character cannot be self")
      true
    end

    def process!
      return false unless processable?
      Title.appoint_steward!(@character, @estate)
    end

    def action_points
      1
    end
  end
end
