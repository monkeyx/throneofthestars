module OrderProcessing
  class EmissaryOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @estate ||= character.current_estate
      @noble_house ||= @estate.noble_house if @estate

      return false if (@estate.nil? || !@estate.foreign_to?(character)) && fail!("Not at a foreign estate")
      true
    end

    def valid_for_character?
      character.emissary? && character.current_estate && character.current_estate.foreign_to?(character)
    end
  end
end
