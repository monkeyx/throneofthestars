module OrderProcessing
  class AlterProductionOrder < StewardOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Position", OrderParameter::NUMBER,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @position ||= params[0].parameter_value_obj.to_i
      @quantity ||= params[1].parameter_value_obj.to_i

      return false if @position < 0  && fail!("Invalid position")
      return false if @position >= @estate.production_queues.size && fail!("No item at that position in the queue")
      return false if @quantity < 1 && fail!("Nothing to produce")
      true
    end

    def process!
      return false unless processable?
      @estate.alter_production_queue!(@position, @quantity)
      true
    end

    def action_points
      1
    end

  end
end
