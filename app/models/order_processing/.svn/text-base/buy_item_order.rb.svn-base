module OrderProcessing
  class BuyItemOrder < TraderOrder
    def initialize(order)
      super(order)
      @items_bought = false
    end

    def prepare_new_parameters
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
      new_parameter("Max Price", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super
      
      @world ||= character.current_world
      @item ||= params[0].parameter_value_obj
      @quantity ||= params[1].parameter_value_obj.to_i
      @max_price ||= params[2].parameter_value_obj.to_f

      return false if @quantity < 1 && fail!("Nothing to buy")
      return false if !character.current_estate.nil? && character.current_estate.available_shuttle_capacity < @item.mass && fail!("Insufficient shuttle capacity")
      true
    end

    def process!
      return false unless processable?
      qty = MarketItem.buy_item!(character.location, @world, @item, @quantity, @max_price)
      if self.order.stop?
        if qty < @quantity
          @quantity -= qty
          self.order.order_parameters[1].update_attributes!(:parameter_value => @quantity)
          self.order.save!
          fail!("#{@quantity} remaining to buy")
          return false
        end
      end
      @items_bought = qty > 0
    end

    def action_points
      1
    end

    def action_points_on_fail
      @items_bought ? 1 : 0
    end
  end
end
