module OrderProcessing
  class AcceptApprenticeOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Character", OrderParameter::CHARACTER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @novice ||= params[1].parameter_value_obj
      @apprenticeship ||= Apprentice.apprenticeship(@novice).apprentices(character).pending.first

      return false if @apprenticeship.nil? && fail!("No offer to accept")
      return false if !character.current_estate && !character.location_starship? && fail!("Must be at an estate or onboard a starship to accept an apprentice")
      return false if !character.can_have_apprentices? && fail!("Not in a role in which you can accept apprentices. Must be Lord, Lady, Legate or Captain")
      return false if !@apprenticeship.novice.can_become_apprentice? && @apprenticeship.destroy && fail!("Other character can no longer be an apprentice")
      true
    end

    def process!
      return false unless processable?
      @apprenticeship.accept!
    end

    def action_points
      0
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      true
    end
  end
end
