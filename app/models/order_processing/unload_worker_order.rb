module OrderProcessing
  class UnloadWorkerOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Worker", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @estate ||= @starship.location
      @worker ||= params[0].parameter_value_obj
      @quantity ||= params[1].parameter_value_obj.to_i

      return false if !@starship.location_estate? && fail!("Must be docked to unload workers")
      return false if @estate.foreign_to?(@starship) && fail!("Must be docked at own estate to unload workers")
      true
    end

    def process!
      return false unless processable?
      @starship.unload_workers!(@worker,@quantity)
      true
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end
  end
end
