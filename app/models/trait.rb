class Trait < ActiveRecord::Base

  attr_accessible :character, :character_id, :category, :acquired_date

  VIRTUE_CHASTE = "Chaste"
  VIRTUE_INDUSTRIOUS = "Industrious"
  VIRTUE_FORGIVING = "Forgiving"
  VIRTUE_GENEROUS = "Generous"
  VIRTUE_HONEST = "Honest"
  VIRTUE_JUST = "Just"
  VIRTUE_MERCIFUL = "Merciful"
  VIRTUE_MODEST = "Modest"
  VIRTUE_WISE = "Wise"
  VIRTUE_TEMPERATE = "Temperate"
  VIRTUE_VALAROUS = "Valarous"

  VIRTUES = [VIRTUE_CHASTE,VIRTUE_INDUSTRIOUS,VIRTUE_FORGIVING,VIRTUE_GENEROUS,VIRTUE_HONEST,VIRTUE_JUST,VIRTUE_MERCIFUL,VIRTUE_MODEST,VIRTUE_WISE,VIRTUE_TEMPERATE,VIRTUE_VALAROUS]

  VICE_LUSTFUL = "Lustful"
  VICE_LAZY = "Lazy"
  VICE_WRATHFUL = "Wrathful"
  VICE_SELFISH = "Selfish"
  VICE_DECEITFUL = "Deceitful"
  VICE_ARBITRARY = "Arbitrary"
  VICE_CRUEL = "Cruel"
  VICE_PROUD = "Proud"
  VICE_SCEPTICAL = "Sceptical"
  VICE_INDULGENT = "Indulgent"
  VICE_COWARD = "Cowardly"

  VICES = [VICE_LUSTFUL,VICE_LAZY,VICE_WRATHFUL,VICE_SELFISH,VICE_DECEITFUL,VICE_ARBITRARY,VICE_CRUEL,VICE_PROUD,VICE_SCEPTICAL,VICE_INDULGENT,VICE_COWARD]

  MIRROR_VIRTUE = {VIRTUE_CHASTE => VICE_LUSTFUL,
    VIRTUE_INDUSTRIOUS => VICE_LAZY,
    VIRTUE_FORGIVING => VICE_WRATHFUL,
    VIRTUE_GENEROUS => VICE_SELFISH,
    VIRTUE_HONEST => VICE_DECEITFUL,
    VIRTUE_JUST => VICE_ARBITRARY,
    VIRTUE_MERCIFUL => VICE_CRUEL,
    VIRTUE_MODEST => VICE_PROUD,
    VIRTUE_WISE => VICE_SCEPTICAL,
    VIRTUE_TEMPERATE => VICE_INDULGENT,
    VIRTUE_VALAROUS => VICE_COWARD}

  MIRROR_VICE = {VICE_LUSTFUL => VIRTUE_CHASTE,
    VICE_LAZY => VIRTUE_INDUSTRIOUS,
    VICE_WRATHFUL => VIRTUE_FORGIVING,
    VICE_SELFISH => VIRTUE_GENEROUS,
    VICE_DECEITFUL => VIRTUE_HONEST,
    VICE_ARBITRARY => VIRTUE_JUST,
    VICE_CRUEL => VIRTUE_MERCIFUL,
    VICE_PROUD => VIRTUE_MODEST,
    VICE_SCEPTICAL => VIRTUE_WISE,
    VICE_INDULGENT => VIRTUE_TEMPERATE,
    VICE_COWARD => VIRTUE_VALAROUS}

  SPECIAL_INJURED = "Injured"
  SPECIAL_WOUNDED = "Wounded"
  SPECIAL_ILLNESS = "Ill"
  SPECIAL_STRESSED = "Stressed"
  SPECIAL_DEPRESSION = "Depressed"
  SPECIAL_SCHIZO = "Schizophrenic"
  SPECIAL_CRAZED = "Crazed"

  PHYSICAL_HEALTH = [SPECIAL_INJURED,SPECIAL_WOUNDED,SPECIAL_ILLNESS]
  MENTAL_HEALTH = [SPECIAL_STRESSED,SPECIAL_DEPRESSION,SPECIAL_SCHIZO,SPECIAL_CRAZED]

  SPECIAL_STUPID = "Stupid"
  SPECIAL_DEFORMITY = "Deformed"
  SPECIAL_LISP = "Lisping"
  SPECIAL_LAME = "Lame"

  DISABILITIES = [SPECIAL_STUPID,SPECIAL_DEFORMITY,SPECIAL_LISP,SPECIAL_LAME]

  SPECIAL_KINSLAYER = "Kinslayer"
  SPECIAL_HERETIC = "Heretic"
  SPECIAL_EXILED = "Exiled"
  SPECIAL_INBRED = "Inbred"
  SPECIAL_BASTARD = "Bastard"
  SPECIAL_BLOODLUST = "Bloodthirsty"

  OTHER = [SPECIAL_KINSLAYER, SPECIAL_HERETIC, SPECIAL_EXILED, SPECIAL_INBRED, SPECIAL_BASTARD, SPECIAL_BLOODLUST]

  TRAIT_TYPES = VIRTUES + VICES + PHYSICAL_HEALTH + MENTAL_HEALTH + DISABILITIES + OTHER

  belongs_to :character
  validates_inclusion_of :category, :in => TRAIT_TYPES
  game_date :acquired_date

  scope :of, lambda {|character|
    {:conditions => {:character_id => character.id}}
  }

  scope :category, lambda {|category|
    {:conditions => {:category=> category}}
  }

  def virtue?
    VIRTUES.include?(self.category)
  end

  def vice?
    VICES.include?(self.category)
  end

  def special?
    !virtue? && !vice?
  end

  def disability?
    DISABILITIES.include?(celf.category)
  end

  def inheritable?
    virtue? || vice? || disability?
  end

  def opposite_trait
    return MIRROR_VIRTUE[self.category] if virtue?
    return MIRROR_VICE[self.category] if vice?
    nil
  end

  def honour_modifier
    return case self.category
    when VIRTUE_CHASTE
      0.25
    when VIRTUE_HONEST
      0.25
    when VICE_DECEITFUL
      -0.25
    when VIRTUE_JUST
      0.25
    when VICE_ARBITRARY
      -0.25
    when VIRTUE_MERCIFUL
      0.25
    when VICE_INDULGENT
      -0.1
    else
      0
    end
  end

  def glory_modifier
    return case self.category
    when VICE_CRUEL
      0.25
    when VIRTUE_MODEST
      -0.25
    when VICE_PROUD
      0.25
    when VIRTUE_TEMPERATE
      -0.25
    when VIRTUE_VALAROUS
      0.25
    when VICE_COWARD
      -0.25
    else
      0
    end
  end

  def piety_modifier
    return case self.category
    when VICE_LUSTFUL
      -0.5
    when VIRTUE_GENEROUS
      0.1
    when VICE_SELFISH
      -0.1
    when VICE_SCEPTICAL
      -0.5
    when VIRTUE_WISE
      0.5
    else
      0
    end
  end

  def offspring_modifier
    return case self.category
    when VIRTUE_CHASTE
      -5
    when VICE_LUSTFUL
      5
    when SPECIAL_STRESSED
      -5
    when SPECIAL_DEPRESSION
      -5
    else
      0
    end
  end

  def action_point_modifier
    return case self.category
    when VIRTUE_INDUSTRIOUS
      0.25
    when VICE_LAZY
      -0.25
    when SPECIAL_INJURED
      -0.25
    when SPECIAL_WOUNDED
      -0.5
    when SPECIAL_ILLNESS
      -0.5
    when SPECIAL_STRESSED
      -0.1
    when SPECIAL_DEPRESSION
      -0.25
    when SPECIAL_SCHIZO
      -0.25
    when SPECIAL_CRAZED
      -0.25
    when SPECIAL_STUPID
      -0.5
    when SPECIAL_LAME
      -0.75
    else
      0
    end
  end

  def life_expectancy_modifier
    return case self.category
    when VIRTUE_INDUSTRIOUS
      -0.15
    when VIRTUE_WISE
      0.1
    when VICE_INDULGENT
      -0.1
    else
      0
    end
  end

  def influence_modifier
    return case self.category
    when VICE_LAZY
      -1
    when VIRTUE_FORGIVING
      2
    when VICE_WRATHFUL
      -2
    when VIRTUE_GENEROUS
      2
    when VICE_SELFISH
      -2
    when VIRTUE_HONEST
      -1
    when VICE_DECEITFUL
      2
    when VIRTUE_JUST
      2
    when VICE_ARBITRARY
      -2
    when VIRTUE_MERCIFUL
      1
    when VICE_CRUEL
      -2
    when VIRTUE_MODEST
      1
    when VICE_PROUD
      -1
    when VIRTUE_WISE
      2
    when VIRTUE_VALAROUS
      2
    when VICE_COWARD
      -2
    when SPECIAL_KINSLAYER
      -2
    when SPECIAL_HERETIC
      -4
    when SPECIAL_EXILED
      -4
    when SPECIAL_DEFORMITY
      -4
    when SPECIAL_LISP
      -2
    when SPECIAL_BLOODLUST
      -2
    else
      0
    end
  end

  def intimidation_modifier
    return case self.category
    when VIRTUE_FORGIVING
      -2
    when VICE_WRATHFUL
      2
    when VIRTUE_MERCIFUL
      -1
    when VICE_CRUEL
      2
    when VIRTUE_VALAROUS
      2
    when VICE_COWARD
      -2
    when SPECIAL_KINSLAYER
      2
    when SPECIAL_BLOODLUST
      2
    else
      0
    end
  end

  def cannot_be_major?
    (self.category == SPECIAL_BASTARD)
  end

  def cannot_marry?
     (self.category == SPECIAL_HERETIC || self.category == SPECIAL_EXILED)
  end

  def cannot_join_clergy?
    (self.category == SPECIAL_HERETIC)
  end

  def cannot_inherit?
    (self.category == SPECIAL_HERETIC || self.category == SPECIAL_EXILED || self.category == SPECIAL_BASTARD)
  end

  def lose_nobility?
    (self.category == SPECIAL_EXILED)
  end

  def lose_ecclesiastical?
    (self.category == SPECIAL_HERETIC)
  end

  def lose_health
    return case self.category
    when SPECIAL_INJURED
      25
    when SPECIAL_WOUNDED
      50
    when SPECIAL_ILLNESS
      50
    when SPECIAL_STRESSED
      10
    when SPECIAL_DEPRESSION
      10
    when SPECIAL_SCHIZO
      15
    when SPECIAL_CRAZED
      15
    when SPECIAL_DEFORMITY
      10
    when SPECIAL_LAME
      25
    else
      0
    end
  end

  def chance_of_death
    return case self.category
    when SPECIAL_WOUNDED
      "1 in 1d20".chance
    when SPECIAL_ILLNESS
      "1 in 1d20".chance
    else
      nil
    end
  end

  def chance_of_depression
    return "1 in 1d20".chance if self.category == SPECIAL_STRESSED
    nil
  end

  def chance_of_schizo
    return "1 in 1d20".chance if self.category == SPECIAL_DEPRESSION
    nil
  end

  def chance_of_crazed
    return "1 in 1d20".chance if self.category == SPECIAL_SCHIZO
    nil
  end

  def chance_of_murder
    return "1 in 1d20".chance if self.category == SPECIAL_CRAZED
    nil
  end

  def to_s
    self.category
  end
end


