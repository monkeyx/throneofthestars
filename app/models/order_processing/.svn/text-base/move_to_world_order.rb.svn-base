module OrderProcessing
  class MoveToWorldOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("World", OrderParameter::WORLD,true)
    end

    def processable?
      return false unless super

      @world ||= params[0].parameter_value_obj

      calculate_action_points if @starship
      return false if !@starship.orbiting? && fail!("Must be in orbit to move to another world")
      return false if !@starship.can_move? && fail!("Ship incapable of travel to another world")
      true
    end

    def process!
      return false unless processable?
      @starship.move!(@world)
      true
    end

    def variable_points_cost?
      true
    end

    def action_points
      @action_points
    end

    def calculate_action_points
      return nil unless character.current_starship
      return nil unless params && params[0] && params[0].parameter_value_obj
      @action_points ||= character.location.calculate_movement_cost(params[0].parameter_value_obj)
    end
  end
end
