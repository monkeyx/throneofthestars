module OrderProcessing
  class JoinTournamentOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @estate ||= character.current_estate
      @tournament ||= @estate.next_tournament if @estate

      return false if !(@estate && @estate.holding_tournament?) && fail!("Must be at an estate holding a tournament")
      true
    end

    def process!
      return false unless processable?
      @tournament.join!(character)
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      character.current_estate
    end
  end
end
