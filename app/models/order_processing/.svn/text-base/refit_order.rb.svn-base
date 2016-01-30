module OrderProcessing
  class RefitOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false unless super

      @estate ||= @starship.location

      return false if !@starship.location_estate? && fail!("Must be docked to refit")
      return false if @estate.foreign_to?(@starship) && fail!("Must be docked at own estate to refit")
      true
    end

    def process!
      return false unless processable?
      @starship.refit! > 0
    end

    def action_points
      4
    end
  end
end
