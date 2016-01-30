module OrderProcessing
  class AddWeddingItemsOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Bride", OrderParameter::BRIDE,true)
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @bride ||= params[0].parameter_value_obj
      @item ||= params[1].parameter_value_obj
      @quantity ||= params[2].parameter_value_obj.to_i
      @wedding ||= @bride.wedding

      return false if !@wedding || @wedding.estate_id != @estate.id && fail!("May only set catering and gifts to weddings to be held at Estate #{@estate.name}")
      return false if @wedding.past? && fail!("Wedding has already taken place")
      return false if !(@item.catering? || @item.gift?) && fail!("Item is not suitable for catering or as a gift")
      true
    end

    def process!
      return false unless processable?
      @wedding.add_item!(@item,@quantity)
      true
    end

    def action_points
      0
    end

    def action_points_on_fail
      0
    end

  end
end

