module OrderProcessing
  class ConstructBuildingOrder < ManagementOrder
    def initialize(order)
      super(order)
      @built_levels = nil
    end

    def prepare_new_parameters
      new_parameter("Building", OrderParameter::BUILDING_TYPE,true)
      new_parameter("Levels", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @building ||= params[0].parameter_value_obj
      @levels ||= params[1].parameter_value_obj.to_i

      return false if @levels < 1 && fail!("Nothing to build")
      return false if !@estate.has_space? && fail!("No free land to build on in estate")
      return false if @building.position_has_raw_materials_for(@estate) < 1 && fail!("Insufficient raw materials")
      return false if @building.max_building_level(@estate.region) < Building.building_level(@estate,@building) && fail!("Maximum building level reached")
      true
    end

    def process!
      return false unless processable?
      @built_levels = 0
      @levels.times do |n|
        if !@estate.construct!(@building)
          if self.order.stop?
            self.order.order_parameters[1].update_attributes!(:parameter_value => (@levels - n))
            self.order.save!
          end
          fail!("Built #{n} levels")
          return false
        else
          @built_levels += 1
        end
      end
      true
    end

    def action_points
      4
    end

    def action_points_on_fail
      @built_levels && @built_levels > 0 ? 4 : 0
    end
  end
end
