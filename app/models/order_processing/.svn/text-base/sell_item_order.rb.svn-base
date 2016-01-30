module OrderProcessing
  class SellItemOrder < TraderOrder
    def initialize(order)
      super(order)
      @items_sold = false
    end

    def prepare_new_parameters
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
      new_parameter("Price", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super
      
      @item ||= params[0].parameter_value_obj
      @quantity ||= params[1].parameter_value_obj.to_i
      @price ||= params[2].parameter_value_obj.to_f

      return false if @quantity < 1 && fail!("Nothing to sell")
      return false if !character.current_estate.nil? && !character.current_estate.can_sell_on_market? && fail!("Estate doesn't have a Trade Hall")
      true
    end

    def process!
      return false unless processable?
      qty = MarketItem.sell_item!(character.location, character.current_world, @item, @quantity, @price)
      if self.order.stop?
        if qty < @quantity
          @quantity -= qty
          self.order.order_parameters[1].update_attributes!(:parameter_value => @quantity)
          self.order.save!
          fail!("#{@quantity} remaining to sell")
          return false
        end
      end
      @items_sold = qty > 0
      true
    end

    def action_points
      1
    end

    def action_points_on_fail
      @items_sold ? 1 : 0
    end
  end
end
