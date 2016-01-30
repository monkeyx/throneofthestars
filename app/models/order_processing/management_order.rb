module OrderProcessing
  class ManagementOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!

      @estate ||= character.current_estate

      return false if @estate.nil? && fail!("Not at an estate")
      true
    end

    def valid_for_character?
      character.management? && character.current_estate
    end
  end
end
