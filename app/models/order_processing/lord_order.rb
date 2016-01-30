module OrderProcessing
  class LordOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @estate ||= character.current_estate

      return false if @estate.nil? && fail!("Not at an estate")
      return false if @estate.lord_id != character.id && fail!("Not lord of the estate")
      true
    end

    def valid_for_character?
      character.lord? && character.current_estate && character.current_estate.lord_id == character.id
    end
  end
end
