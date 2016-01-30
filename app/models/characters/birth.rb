module Characters
  module Birth
    def chance_for_child
      return nil unless adult? && male? && self.spouse # only male characters are considered
      base = 1
      base += 1 if self.spouse.age < 30
      base += 2 if self.spouse.age < 18
      base -= 2 if self.spouse.age > 40
      base -= 2 if self.spouse.age > 50
      if location_estate?
        base += self.location.region.season_birth_modifier
      end
      base += sum_trait_modifiers(:offspring_modifier)
      "#{base} in 1d100".chance
    end

    def chance_for_bastard
      return nil unless adult? && male?
      base = 0
      if away_from_home?
        base = 1
        base += sum_trait_modifiers(:offspring_modifier)
      elsif lord?
        base = 1 if has_trait?(Trait::VICE_LUSTFUL)
      end
      "#{base} in 1d100".chance
    end

    def check_for_legitimate_birth!
      chance = chance_for_child
      return if chance.nil?
      if chance.success?
        birthplace = self.location if location_estate?
        birthplace = self.noble_house.home_estate unless birthplace
        Character.give_birth!(self,self.spouse,birthplace)
      end
    end

    def check_for_illegitimate_birth!
      chance = chance_for_bastard
      return if chance.nil?
      if chance.success?
        birthplace = self.noble_house.home_estate unless birthplace
        Character.give_birth!(self,nil,birthplace,Game.current_date,Character::MALE)
      end
    end

  end
end
