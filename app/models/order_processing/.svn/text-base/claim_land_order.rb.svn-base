module OrderProcessing
  class ClaimLandOrder < LordOrder
    def initialize(order)
      super(order)
      @land_claimed = false
    end

    def prepare_new_parameters
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super
      
      @quantity ||= params[0].parameter_value_obj.to_i

      return false if @quantity < 1 && fail!("No quantity specified")
      true
    end

    def process!
      return false unless processable?
      qty = @estate.claim_lands!(@quantity)
      if self.order.stop?
        if qty < @quantity
          @quantity -= qty
          self.order.order_parameters[0].update_attributes!(:parameter_value => @quantity)
          self.order.save!
          fail!("#{@quantity} lands remaining to be claimed")
          return false
        end
      end
      @land_claimed = qty > 0
      true
    end

    def action_points
      2
    end

    def action_points_on_fail
      @land_claimed ? 2 : 0
    end

  end
end
