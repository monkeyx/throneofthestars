module Characters
  module Health
    def infant_health_check!
      infant_injury_check!
      infant_illness_check!
      infant_death_check!
    end

    def infant_death_check!
      return unless age < 7
      unless self.location && self.location_estate?
        return die! unless move_to_home_estate!
      end
      base = 0
      base += 1 if age < 2
      base += 1 if age < 4
      if self.location && self.location.region
        base += self.location.region.season_infant_death_modifier
      else
        base += 10
      end
      base += 10 if parent_crazy?
      base += 10 if parent_kinslayer?
      base = 100 - base
      die! if "#{base} on 1d100".success?
    end

    def infant_injury_check!
      return unless age < 7
      unless self.location && self.location_estate?
        return die! unless move_to_home_estate!
      end
      base = 1
      base += 1 if age < 2
      base += 1 if age < 4
      if self.location && self.location.region
        base += self.location.region.season_infant_injury_modifier 
      else
        base += 10
      end
      base += 10 if parent_crazy?
      base += 10 if parent_kinslayer?
      base = 100 - base
      injured! if "#{base} on 1d100".success?
    end

    def infant_illness_check!
      return unless age < 7
      unless self.location && self.location_estate?
        return die! unless move_to_home_estate!
      end
      base = 1
      base += 1 if age < 2
      base += 1 if age < 4
      if self.location && self.location.region
        base += self.location.region.season_infant_illness_modifier
      else
        base += 10
      end
      base = 100 - base
      ill! if "#{base} on 1d100".success?
    end

    def adult_health_check!
      ill! if "#{100 - health} in 1d100".success?
      stressed! if !unemployed? && "100 on 1d100".success?
      return die!("poor health") if health < 20 && "#{health} on 1d20".success?
      self.traits.each do |trait|
        death_chance = trait.chance_of_death
        return die! if death_chance && death_chance.success?
        chance_of_depression = trait.chance_of_depression
        add_trait!(Trait::SPECIAL_DEPRESSION) if chance_of_depression && chance_of_depression.success?
        chance_of_schizo = trait.chance_of_schizo
        add_trait!(Trait::SPECIAL_SCHIZO) if chance_of_schizo && chance_of_schizo.success?
        chance_of_crazed = trait.chance_of_crazed
        add_trait!(Trait::SPECIAL_CRAZED) if chance_of_crazed && chance_of_crazed.success?
        chance_of_murder = trait.chance_of_murder
        if chance_of_murder && chance_of_murder.success?
          list = self.children.map{|child| return child if child.current_estate && self.current_estate && child.current_estate.id == self.current_estate.id}
                + self.siblings(true, true).map{|sibling| return sibling if sibling.current_estate == self.current_estate}
          self.assassinate!(list.sample) if list.size > 0
        end
      end
      true
    end

    def recovery_check!
      recovery_chance = "9 on 1d10".chance
      if current_estate
        hospital_level = current_estate.building_level(BuildingType.building_type(BuildingType::HOSPITAL))
        recovery_chance = recovery_chance + hospital_level if recovery_chance > 0
      else
        hospital_level = 0
      end
      remove_trait!(Trait::SPECIAL_INJURED) if has_trait?(Trait::SPECIAL_INJURED) && recovery_chance.success?
      remove_trait!(Trait::SPECIAL_ILLNESS) if has_trait?(Trait::SPECIAL_ILLNESS) && recovery_chance.success?
      remove_trait!(Trait::SPECIAL_STRESSED) if has_trait?(Trait::SPECIAL_STRESSED) && recovery_chance.success?
      if hospital_level > 0
        remove_trait!(Trait::SPECIAL_WOUNDED) if has_trait?(Trait::SPECIAL_WOUNDED) && recovery_chance.success?
      end
    end

    def health_check!
      infant_health_check! if infant?
      adult_health_check! if adult?
      recovery_check!
    end

    def cured!
      remove_trait!(Trait::SPECIAL_WOUNDED)
      remove_trait!(Trait::SPECIAL_INJURED)
      remove_trait!(Trait::SPECIAL_ILLNESS)
    end

    def heal!(other_character)
      medicine_rank = skill_rank(Skill::CHURCH_MEDICINE)
      return false unless medicine_rank > 0
      injuries_chance = "5 on 1d10+#{(medicine_rank - 1)}".chance
      wounds_chance = "6 on 1d10+#{(medicine_rank - 1)}".chance
      illness_chance = "4 on 1d10+#{(medicine_rank - 1)}".chance
      return true if heal_trait!(other_character, Trait::SPECIAL_WOUNDED, wounds_chance, "HEAL_WOUND")
      return true if heal_trait!(other_character, Trait::SPECIAL_INJURED, injuries_chance, "HEAL_INJURY")
      return true if heal_trait!(other_character, Trait::SPECIAL_ILLNESS, illness_chance, "HEAL_ILLNESS")
      false
    end

    def heal_trait!(other_character, trait, chance, success_news_code)
      if other_character.has_trait?(trait)
        if chance.success?
          other_character.remove_trait!(trait)
          add_news!(success_news_code, other_character)
        elsif chance.rolled == 1
          other_character.die!("malpractice")
          add_news("HEAL_FATAL", other_character)
        end
        return true
      end
      false
    end
  end
end
