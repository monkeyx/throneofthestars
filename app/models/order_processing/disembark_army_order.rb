module OrderProcessing
  class DisembarkArmyOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Army", OrderParameter::OWN_ARMY,true)
    end

    def processable?
      return false unless super

      @army ||= params[0].parameter_value_obj

      return false if !(@army.location_type == 'Starship' && @army.location_id == @starship.id) && fail!("Army #{@army.name} is not onboard Starship #{@starship.name}")
      true
    end

    def process!
      return false unless processable?
      @starship.disembark_army!(@army)
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
