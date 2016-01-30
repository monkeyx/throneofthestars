module OrderProcessing
  class TraderOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      return false if character.location_starship? && !character.location.can_trade? && fail!("Starship is incapable of trade at this location")
      return false if !character.current_world && fail!("Not at world to trade")
      true
    end

    def valid_for_character?
      character.trader? && character.current_world
    end
  end
end
