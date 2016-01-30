module OrderProcessing
  class GatherResourcesOrder < LordOrder
    def initialize(order)
      super(order)
      @amount_collected = 0
    end

    def prepare_new_parameters
    end

    def processable?
      return false unless super

      @amount_collected = 0
      
      true
    end

    def process!
      return false unless processable?
      @amount_collected = @estate.automated_resource_gathering!
      if @amount_collected > 0
        return true
      else
        fail!("No resources collected")
        return false
      end
    end

    def action_points
      4
    end

    def action_points_on_fail
      @amount_collected > 0 ? 4 : 0
    end
  end
end
