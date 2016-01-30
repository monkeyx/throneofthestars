module OrderProcessing
  class CancelSaleItemOrder < TraderOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Price", OrderParameter::NUMBER,true)
    end

    def processable?
      return false  unless super
      
      @world ||= character.current_world
      @item ||= params[0].parameter_value_obj
      @price ||= params[1].parameter_value_obj.to_f

      return false if character.location_starship? && !character.location.can_trade? && fail!("Starship is incapable of trade at this location")
      return false if @world.nil? && fail!("Not at world to cancel a sale")
      return false if !character.current_estate.nil? && character.current_estate.available_shuttle_capacity < @item.mass && fail!("Insufficient shuttle capacity")
      true
    end

    def process!
      return false unless processable?
      qty = MarketItem.cancel_item!(character.location, character.current_world, @item, @price)
      if qty < 1
        fail!("Nothing cancelled")
        return false
      end
      true
    end

    def action_points
      1
    end

  end
end
