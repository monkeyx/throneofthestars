module OrderProcessing
  class AddProductionOrder < StewardOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @item ||= params[0].parameter_value_obj
      @quantity ||= params[1].parameter_value_obj.to_i

      return false if @quantity < 1 && fail!("Nothing to produce")
      return false if @item.restricted? && !@estate.region.world.has_project?(@item.project_required) && fail!("Item requires #{@item.project_required}")
      true
    end

    def process!
      return false unless processable?
      @estate.add_item_to_queue!(@item, @quantity)
      true
    end

    def action_points
      1
    end

  end
end
