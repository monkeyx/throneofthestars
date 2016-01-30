module OrderProcessing
  class ScuttleOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false unless super

      return false if !@starship.orbiting? && fail!("Must be in orbit")
      true
    end

    def process!
      return false unless processable?
      @starship.breakdown!
    end

    def action_points
      4
    end
  end
end
