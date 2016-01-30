module OrderProcessing
  class FormArmyOrder < LordOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Name", OrderParameter::TEXT,true)
      new_parameter("Legate", OrderParameter::OWN_CHARACTER, false)
    end

    def processable?
      return false unless super
      
      @name ||= params[0].parameter_value_obj
      @legate ||= params[1].parameter_value_obj

      if @legate
        return false if !@legate.at_same_estate?(character.current_estate) && fail!("Legate must be at the estate")
        return false if !@legate.male? && fail!("Legate must be male")
        return false if !@legate.adult? && fail!("Legate must be an adult")
      end
      true
    end

    def process!
      return false unless processable?
      Army.create_army!(@name, character.current_estate, @legate)
    end

    def action_points
      2
    end

  end
end
