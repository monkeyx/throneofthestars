module OrderProcessing
  class StewardOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!

      @estate ||= character.current_estate

      return false if @estate.nil? && fail!("Not at an estate")
      return false if @estate.steward_id != character.id && fail!("Not steward of the estate")
      true
    end

    def valid_for_character?
      character.steward? && character.current_estate && character.current_estate.steward_id == character.id
    end
  end
end
