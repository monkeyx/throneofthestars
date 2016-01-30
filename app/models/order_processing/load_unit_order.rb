module OrderProcessing
  class LoadUnitOrder < LegateOrder
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
      max_quantity = @estate.count_item(@item)
      @quantity = max_quantity if @quantity > max_quantity
      return false if @quantity < 1 && fail!("No item available at estate")
      max_space = @unit.space_available_for(@item)
      @quantity = max_space if @quantity > max_space
      return false if @quantity < 1 && fail!("Unit cannot load item")
      return false if @unit.army_id != @army.id && fail!("Not a unit of own army")
      return false if @item.immobile? && fail!("Cannot move #{@item.name}")
      true
    end

    def process!
      return false unless processable?
      @estate.remove_item!(@item, @quantity)
      @unit.add_item!(@item, @quantity)
      @army.add_news!("UNIT_LOAD", "#{@unit.name} with #{@quantity} x #{@item.name.pluralize_if(@quantity)}")
    end

    def action_points
      1
    end
  end
end
