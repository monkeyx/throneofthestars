module OrderProcessing
  class CaptainOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @starship ||= character.current_starship
      
      return false if (@starship.nil? || @starship.captain_id != character.id) && fail!("Not captain of a starship")
      true
    end

    def valid_for_character?
      character.captain? && character.current_starship
    end
  end
end
