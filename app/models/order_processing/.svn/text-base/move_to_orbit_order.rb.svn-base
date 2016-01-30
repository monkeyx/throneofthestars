module OrderProcessing
  class MoveToOrbitOrder < LegateOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false unless super
      
      return false if !@army.orbital_allowed? && fail!("Army incapable of orbital movement")
      true
    end

    def process!
      return false unless processable?
      @army.move!
    end

    def variable_points_cost?
      true
    end

    def action_points
      character.current_army.adjusted_movement_cost
    end
  end
end
