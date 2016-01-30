module Characters
  module Combat
    SWORD_FIGHT = "Swords"
    LANCE_FIGHT = "Lances"
    PISTOL_FIGHT = "Pistols"

    PERSONAL_COMBAT = [SWORD_FIGHT, LANCE_FIGHT, PISTOL_FIGHT]

    def personal_combat!(other_character,personal_combat_type)
      winner = nil
      loser = nil
      while winner.nil? do
        case personal_combat_type
        when SWORD_FIGHT
          r1 = self.sword_dice.roll
          r2 = other_character.sword_dice.roll
        when LANCE_FIGHT
          r1 = self.lance_dice.roll
          r2 = other_character.lance_dice.roll
        when PISTOL_FIGHT
          r1 = self.pistols_dice.roll
          r2 = other_character.pistols_dice.roll
        end
        if r1 > r2
          winner = self
          loser = other_character
        elsif r1 < r2
          winner = other_character
          loser = self
        end
      end
      injured = false
      wounded = false
      died = false
      roll = "1d10".roll
      case personal_combat_type
      when SWORD_FIGHT
        winner.sword_fight_experience!
        case roll
        when 10
          died = true
          winner.add_trait!(Trait::SPECIAL_BLOODLUST)
        when 9
          wounded = true
        when 8
          injured = true
        end
      when LANCE_FIGHT
        winner.lance_fight_experience!
        case roll
        when 10
          died = true
          winner.add_trait!(Trait::SPECIAL_BLOODLUST)
        when 9
          died = true
          winner.add_trait!(Trait::SPECIAL_BLOODLUST)
        when 8
          wounded = true
        when 7
          injured = true
        end
      when PISTOL_FIGHT
        if roll >= 6
          died = true
          winner.add_trait!(Trait::SPECIAL_BLOODLUST)
        elsif roll >= 4
          wounded = true
        elsif roll >= 3
          injured = true
        end
      end
      if died
        loser.die!("defeat in a fight with #{personal_combat_type.downcase}")
      elsif wounded
        loser.wounded!
      elsif injured
        loser.injured!
      end
      winner.add_news!("WIN_PERSONAL_COMBAT",loser)
      winner
    end

    def sword_dice
      modifier = sum_skill_modifiers(:sword_combat) + self.intimidation
      "1d10+#{modifier}".dice
    end

    def lance_dice
      modifier = sum_skill_modifiers(:lance_combat) + self.intimidation
      "1d10+#{modifier}".dice
    end

    def pistols_dice
      modifier = sum_skill_modifiers(:pistol_combat) + self.intimidation
      "1d10+#{modifier}".dice
    end

  end
end
