module OrderProcessing
  class TrialByChurchOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Character", OrderParameter::CHARACTER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @source ||= params[1].parameter_value_obj
      
      @accusation ||= Accusation.find_accusation(character, @source)     

      return false if !@accusation && fail!("No accusation of injustice from #{@source.display_name} to merit a trial")
      return false if !Law.church_trials? && fail!("No Edict of Forgiveness in place to allow church trials")
      true
    end

    def process!
      return false unless processable?
      @accusation.trial_by_church!
    end

    def action_points
      2
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      true
    end
  end
end
