module OrderProcessing
  class SellWorkersOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
      @workers_sold = false
    end

    def prepare_new_parameters
      new_parameter("Worker", OrderParameter::WORKER_TYPE,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
      new_parameter("Price", OrderParameter::NUMBER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @estate ||= character.current_estate
      @worker_type ||= params[0].parameter_value_obj
      @quantity ||= params[1].parameter_value_obj.to_i
      @price ||= params[2].parameter_value_obj.to_f

      return false if @quantity < 1 && fail!("Nothing to sell")
      return false if !@estate.nil? && !@estate.can_sell_on_market? && fail!("Estate doesn't have a Trade Hall")
      return false if !(@estate.tribune_id == character.id || @estate.lord_id == character.id) && fail!("Must be a steward or lord of the estate")
      true
    end

    def process!
      return false unless processable?
      qty = @estate.sell_worker!(@worker_type, @quantity, @price)
      if self.order.stop?
        if qty < @quantity
          @quantity -= qty
          self.order.order_parameters[1].update_attributes!(:parameter_value => @quantity)
          self.order.save!
          fail!("#{@quantity} remaining to sell")
          return false
        end
      end
      @workers_sold = qty > 0
      true
    end

    def action_points
      2
    end

    def action_points_on_fail
      @workers_sold ? 2 : 0
    end

    def valid_for_character?
      character.human_resources? && character.current_estate
    end
  end
end
