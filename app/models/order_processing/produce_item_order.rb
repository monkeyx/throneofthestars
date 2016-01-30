module OrderProcessing
  class ProduceItemOrder < LordOrder
    def initialize(order)
      super(order)
      @amount_produced = 0
    end

    def prepare_new_parameters
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @amount_produced = 0
      @item ||= params[0].parameter_value_obj
      @quantity ||= params[1].parameter_value_obj.to_i

      return false if @quantity < 1 && fail!("Nothing to produce")
      return false if @item.restricted? && !@estate.region.world.has_project?(@item.project_required) && fail!("Item requires #{@item.project_required}")
      true
    end

    def process!
      return false unless processable?
      @amount_produced = @estate.produce_item!(@item, @quantity)
      if self.order.stop? && (!@amount_produced || @amount_produced < @quantity)
        @quantity -= @amount_produced if @amount_produced
        self.order.order_parameters[1].update_attributes!(:parameter_value => @quantity)
        self.order.save!
        fail!("#{@quantity} remaining to produce")
      end
      if @amount_produced && @amount_produced > 0 && !self.order.stop?
        return true
      elsif !@amount_produced || @amount_produced == 0
        fail!("No item produced - check raw materials needed")
        return false
      else
        return true
      end
    end

    def action_points
      4
    end

    def action_points_on_fail
      @amount_produced && @amount_produced > 0 ? 4 : 0
    end
  end
end
