module OrderProcessing
  class ClearProductionOrder < StewardOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false  unless super

      true
    end

    def process!
      return false unless processable?
      @estate.clear_production_queue!
      true
    end

    def action_points
      4
    end
  end
end
