module OrderProcessing
  class GrantRightsOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @noble_house ||= params[0].parameter_value_obj
      @item ||= params[1].parameter_value_obj
      @quantity ||= params[2].parameter_value_obj.to_i

      counted_items = @estate.count_item(@item)
      @quantity = counted_items if counted_items < @quantity

      return false if @quantity < 1 && fail!("No #{@item.name} at #{@estate.name}")
      true
    end

    def process!
      return false unless processable?
      return false unless @estate.issue_authorisation!(@noble_house,@item,@quantity)
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
