module OrderProcessing
  class BaronOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @noble_house ||= character.noble_house

      return false if @noble_house.home_estate.nil? && fail!("No home estate")
      true
    end

    def valid_for_character?
      character.baron?
    end
  end
end
