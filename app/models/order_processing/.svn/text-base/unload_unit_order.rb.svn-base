module OrderProcessing
  class UnloadUnitOrder < LegateOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Unit", OrderParameter::UNIT,true)
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super
      
      @unit ||= params[0].parameter_value_obj
      @item ||= params[1].parameter_value_obj
      @quantity ||= params[2].parameter_value_obj.to_i

      return false if (@estate.nil? || !@estate.same_house?(character)) && fail!("Not at own estate")
      max_quantity = @unit.count_item(@item)
      @quantity = max_quantity if @quantity > max_quantity
      return false if @quantity < 1 && fail!("No item available at unit")
      return false if @unit.army != @army && fail!("Not a unit of own army")
      return false if @item.immobile? && fail!("Cannot move #{@item.name}")
      true
    end

    def process!
      return false unless processable?
      @unit.remove_item!(@item, @quantity)
      @estate.add_item!(@item, @quantity)
      @army.add_news!("UNIT_UNLOAD", "#{@unit.name} of #{@quantity} x #{@item.name.pluralize_if(@quantity)}")
    end

    def action_points
      2
    end
  end
end
