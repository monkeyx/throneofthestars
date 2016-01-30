module OrderProcessing
  class CaptureShipOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Target", OrderParameter::SCANNED_SHIP,true)
    end

    def processable?
      return false unless super

      @target ||= params[0].parameter_value_obj

      return false if !@starship.orbiting? && fail!("Must be in orbit")
      return false if !@starship.scanned?(@target) && fail!("Not scanned target")
      return false if !@target.same_location?(@starship) && fail!("Not at the same location")
      return false if !@starship.faster?(@target) && fail!("Ship must be faster than target")
      return false if @starship.noble_house_id == @target.noble_house_id && fail!("Cannot capture own ship")
      true
    end

    def process!
      return false unless processable?
      @starship.capture!(@target)
    end

    def action_points
      4
    end
  end
end
