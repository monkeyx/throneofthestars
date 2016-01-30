module OrderProcessing
  class DemolishBuildingOrder < ManagementOrder
    def initialize(order)
      super(order)
      @demolished_levels = nil
    end

    def prepare_new_parameters
      new_parameter("Building", OrderParameter::BUILDING_TYPE,true)
      new_parameter("Levels", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @building_type ||= params[0].parameter_value_obj
      list = Building.at(@estate).building_type(@building_type)
      @building ||= list.first if list.size > 0
      @levels ||= params[1].parameter_value_obj.to_i

      return false if @levels < 1 && fail!("Nothing to demolish")
      return false if @building.nil? || @building.level < 1 && fail!("No building to demolish")
      true
    end

    def process!
      return false unless processable?
      @demolished_levels = @estate.demolish!(@building_type, @levels)
      if @demolished_levels < @levels
        if self.order.stop?
          self.order.order_parameters[1].update_attributes!(:parameter_value => (@levels - @demolished_levels))
          self.order.save!
        end
        if @demolished_levels < 1
          fail!("Failed to demolish anything")
          return false
        else
          fail!("Only demolished #{@demolished_levels} levels")
          return false
        end
      end
      true
    end

    def action_points
      4
    end

    def action_points_on_fail
      @demolished_levels && @demolished_levels > 0 ? 4 : 0
    end

  end
end
