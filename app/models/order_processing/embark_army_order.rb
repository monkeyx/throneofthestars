module OrderProcessing
  class EmbarkArmyOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Army", OrderParameter::OWN_ARMY,true)
    end

    def processable?
      return false unless super

      @army ||= params[0].parameter_value_obj

      return false if !@starship.same_location?(@army) && fail!("Must be in same location as Army #{@army.name}")
      return false if !@starship.space_for_army?(@army) && fail!("Insufficient space to embark #{@army.name}")
      true
    end

    def process!
      return false unless processable?
      @starship.embark_army!(@army)
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
