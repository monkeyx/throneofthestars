module OrderProcessing
  class TakeOffOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false unless super

      return false if !@starship.location_estate? && fail!("Must be docked to take off")
      return false if !@starship.can_take_off? && fail!("Ship incapable of taking off from current location")
      true
    end

    def process!
      return false unless processable?
      @starship.take_off!
      true
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end
  end
end
