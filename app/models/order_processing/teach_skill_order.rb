module OrderProcessing
  class TeachSkillOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Character", OrderParameter::OWN_CHARACTER,true)
      new_parameter("Skill", OrderParameter::SKILL,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @character ||= params[0].parameter_value_obj
      @skill ||= params[1].parameter_value_obj

      return false if @character.id == character.id && fail!("Character cannot be self")
      return false if character.skill_rank(@skill) < Skill::EXPERT && fail!("Must be expert to teach")
      return false if !@character.major? && fail!("Must be a major character to be taught")
      return false if !character.same_location?(@character) && fail!("Must be at same location to be taught")
      return false if @character.skill_rank(@skill) > 0 && fail!("Already knows skill")
      true
    end

    def process!
      return false unless processable?
      character.add_news!("TEACH_SKILL","#{@skill} to #{@character.display_name}")
      @character.add_skill!(@skill)
    end

    def action_points
      4
    end

    def valid_for_character?
      character.expert?
    end
  end
end
