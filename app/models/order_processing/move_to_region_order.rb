module OrderProcessing
  class MoveToRegionOrder < LegateOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("World", OrderParameter::WORLD,true)
      new_parameter("Region", OrderParameter::REGION,true)
    end

    def processable?
      return false unless super
      
      @world ||= params[0].parameter_value_obj
      @region ||= params[1].parameter_value_obj

      return false if !@army.movement_allowed? && fail!("Army incapable of movement")
      return false if (!@army.current_world || @region.world_id != @army.current_world.id) && fail!("Not on same world")
      true
    end

    def process!
      return false unless processable?
      @army.move!(@region)
    end

    def variable_points_cost?
      true
    end

    def action_points
      character.current_army.adjusted_movement_cost
    end
  end
end
