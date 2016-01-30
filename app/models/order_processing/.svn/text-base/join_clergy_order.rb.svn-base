module OrderProcessing
  class JoinClergyOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @estate ||= character.current_estate

      chapel = BuildingType.category(BuildingType::CHAPEL).first

      return false if !character.can_join_clergy? && fail!("#{character.name} cannot join the clergy")
      return false if (!@estate || !@estate.has_building?(chapel)) && fail!("Must be at an estate with a chapel to join the clergy")
      true
    end

    def process!
      return false unless processable?
      Title.become_acolyte!(character, @estate)
      true
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
