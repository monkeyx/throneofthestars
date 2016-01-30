module OrderProcessing
  class SabotageOrder < EmissaryOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Building", OrderParameter::BUILDING_TYPE, false)
       new_parameter("Item", OrderParameter::ITEM, false)
    end

    def processable?
      return false unless super

      @building_type ||= params[0].parameter_value_obj
      @item ||= params[1].parameter_value_obj

      return false if (@building_type.nil? && @item.nil?) && fail!("Nothing to be sabotage")
      return false if (@building_type && @item) && fail!("You must choose either a building or item to sabotage")

      true
    end

    def process!
      return false unless processable?
      character.sabotage!(@building_type,@item)
    end

    def action_points
      4
    end

  end
end
