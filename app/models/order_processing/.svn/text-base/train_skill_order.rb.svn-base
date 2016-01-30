module OrderProcessing
  class TrainSkillOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Skill", OrderParameter::SKILL,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @skill ||= params[0].parameter_value_obj

      return false if !character.major? && character.skill_rank(@skill) < Skill::NEOPHYTE && character.highest_rank_of_skill > 0 && fail!("Must be a major character to train a new skill ")
      return false if !character.can_train_skill?(@skill) && fail!("Not in right role to train this skill")
      return false if character.skill_rank(@skill) > Skill::EXPERT && fail!("Already mastered skill")
      true
    end

    def process!
      return false unless processable?
      character.train!(@skill)
    end

    def action_points
      1
    end

    def valid_for_character?
      character.employed?
    end
  end
end
