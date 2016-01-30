module OrderProcessing
  class AttackArmiesOrder < LegateOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE_INCLUDE_ANCIENT,true)
    end

    def processable?
      return false unless super
      
      @target_house ||= params[0].parameter_value_obj
      
      return false if !character.noble_house.at_war?(@target_house) && fail!("Must be at war")
      return false if !(@army.location_region? || @army.location_estate?) && fail!("Must be on land to attack")
      return false if (@army.current_region.nil? || @army.current_region.current_season == Region::WINTER) && fail!("No ground combat in winter")
      true
    end

    def process!
      return false unless processable?
      unless @army.atttack_house_armies!(@target_house)
        fail!("No armies belonging to House #{@target_house.name} found at #{@army.location.name}") if Army.at(@army.location).of(@target_house).empty?
        return false
      end
      true
    end

    def action_points
      4
    end

  end
end
