module OrderProcessing
  class SalvageOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Scanned Ship", OrderParameter::SCANNED_SHIP,true)
    end

    def processable?
      return false unless super

      @scanned_ship ||= params[0].parameter_value_obj

      return false if !@starship.orbiting? && fail!("Must be in orbit")
      return false if !@starship.scanned?(@scanned_ship) && fail!("#{@starship.name} has not scanned target")
      return false if !@scanned_ship.debris? && fail!("#{@scanned_ship.name} is not a debris field")
      true
    end

    def process!
      return false unless processable?
      @starship.salvage!(@scanned_ship)
      true
    end

    def action_points
      2
    end

    def action_points_on_fail
      0
    end
  end
end
