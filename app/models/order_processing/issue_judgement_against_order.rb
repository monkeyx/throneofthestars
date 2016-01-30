module OrderProcessing
  class IssueJudgementAgainstOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Character", OrderParameter::CHARACTER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @against ||= params[1].parameter_value_obj
      
      if character.emperor?
        @accusations ||= Accusation.concerning(@against).court_trial
      elsif character.pontiff?
        @accusations ||= Accusation.concerning(@against).church_trial
      end
      
      return false if @accusations.empty? && fail!("No accusation of injustice concerning #{@against.display_name} to merit a judgement")
      true
    end

    def process!
      return false unless processable?
      @accusations.each{|accusation| accusation.judge_against!(@against)}
    end

    def action_points
      2
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      character.pontiff_or_emperor?
    end
  end
end
