module OrderProcessing
  class CreateUnitOrder < LegateOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Name", OrderParameter::TEXT,true)
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super
      
      @name ||= params[0].parameter_value_obj
      @item ||= params[1].parameter_value_obj
      @quantity ||= params[2].parameter_value_obj.to_i

      return false if (@estate.nil? || !@estate.same_house?(character)) && fail!("Not at own estate")
      max_quantity = @estate.count_item(@item)
      @quantity = max_quantity if @quantity > max_quantity
      return false if @quantity < 1 && fail!("No item available at estate")
      return false if @item.immobile? && fail!("Cannot move #{@item.name}")
      true
    end

    def process!
      return false unless processable?
      @estate.remove_item!(@item, @quantity)
      @army.create_unit!(@name, @item, @quantity)
    end

    def action_points
      2
    end

  end
end
