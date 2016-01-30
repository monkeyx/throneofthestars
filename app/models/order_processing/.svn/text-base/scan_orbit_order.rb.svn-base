module OrderProcessing
  class ScanOrbitOrder < CaptainOrder
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
      unless @starship.scan_orbit!
        fail!("Nothing scanned in orbit")
        return false
      end
      true
    end

    def action_points
      1
    end

    def action_points_on_fail
      @starship && @starship.orbiting? ? 1 : 0
    end
  end
end
