module SkillsHelper
  def options_for_skills(selected,skill_types = Skill::SKILL_TYPES)
    options_for_select(skill_types,selected)
  end

  def options_for_ranks(max=4)
    list = []
    (max-1).times do |n|
      list << [Skill::RANK_NAMES[n], n]
    end
    options_for_select(list)
  end

  def skill_rank(rank)
    Skill::RANK_NAMES[rank].html_safe
  end
end
