module Characters
  module Emissary
    LOW_BRIBE = 10000
    MODEST_BRIBE = 25000
    BIG_BRIBE = 50000

    NO_BRIBE_SCORE = 8
    LOW_BRIBE_SCORE = 6
    MODEST_BRIBE_SCORE = 4
    BIG_BRIBE_SCORE = 2

    MORE_HONOUR_MODIFIER = 2

    PETITION_MAJOR_SUCCESS_DIFFERENCE = 2
    PETITION_DISASTER_ROLL = 1

    PETITION_MAJOR_SUCCESS = 25
    PETITION_MINOR_SUCCESS = 10

    INFORMATION_ARMIES = 'Armies'
    INFORMATION_SPACESHIPS = 'Spaceships'
    INFORMATION_BUILDINGS = 'Buildings'
    INFORMATION_NON_MILITARY = 'Non-Military Inventory'
    INFORMATION_MILITARY = 'Military Inventory'
    INFORMATION_PRODUCTION = 'Production Queue'
    INFORMATION_TYPES = [INFORMATION_ARMIES, INFORMATION_SPACESHIPS, INFORMATION_BUILDINGS, INFORMATION_NON_MILITARY, INFORMATION_MILITARY, INFORMATION_PRODUCTION]

    INFORMATION_BASE_CHANCE = {
      INFORMATION_ARMIES => "5 on 1d8".chance,
      INFORMATION_SPACESHIPS => "5 on 1d8".chance,
      INFORMATION_BUILDINGS => "4 on 1d8".chance,
      INFORMATION_NON_MILITARY => "4 on 1d8".chance,
      INFORMATION_MILITARY => "7 on 1d8".chance,
      INFORMATION_PRODUCTION => "8 on 1d8".chance
    }

    INFORMATION_DISCOVERY_CHANCE = {
      INFORMATION_ARMIES => "8 on 1d8".chance,
      INFORMATION_SPACESHIPS => "7 on 1d8".chance,
      INFORMATION_BUILDINGS => "8 on 1d8".chance,
      INFORMATION_NON_MILITARY => "8 on 1d8".chance,
      INFORMATION_MILITARY => "5 on 1d8".chance,
      INFORMATION_PRODUCTION => "4 on 1d8".chance
    }

    SABOTAGE_ORE_TRADE_GOOD = "4 on 1d8".chance
    SABOTAGE_RECRUITMENT_MODULES = "6 on 1d8".chance
    SABOTAGE_TRADE_NAVAL = "8 on 1d8".chance
    SABOTAGE_PALACE_MILITARY = "10 on 1d8".chance
    SABOTAGE_OTHER = "9 on 1d8".chance

    SABOTAGE_DISCOVERED_ORE_TRADE_GOOD = "8 on 1d8".chance
    SABOTAGE_DISCOVERED_RECRUITMENT_MODULES = "7 on 1d8".chance
    SABOTAGE_DISCOVERED_TRADE_NAVAL = "6 on 1d8".chance
    SABOTAGE_DISCOVERED_PALACE_MILITARY = "4 on 1d8".chance
    SABOTAGE_DISCOVERED_OTHER = "5 on 1d8".chance

    ASSASSINATION_NOBLE = "8 on 1d8".chance
    ASSASSINATION_CHURCH = "7 on 1d8".chance
    ASSASSINATION_OTHER = "6 on 1d8".chance

    ASSASSINATION_DISCOVERED_NOBLE = "4 on 1d8".chance
    ASSASSINATION_DISCOVERED_CHURCH = "6 on 1d8".chance
    ASSASSINATION_DISCOVERED_OTHER = "8 on 1d8".chance

    def chance_influence(other_character,bribe=0)
      modifier = self.influence - other_character.influence + (other_character.liege ? other_character.liege.influence : 0) + sum_skill_modifiers(:influence)
      modifier -= MORE_HONOUR_MODIFIER if self.noble_house.honour < other_character.noble_house.honour
      modifier += MORE_HONOUR_MODIFIER if self.noble_house.honour > other_character.noble_house.honour
      chance = bribe < LOW_BRIBE ? NO_BRIBE_SCORE : bribe < MODEST_BRIBE ?  LOW_BRIBE_SCORE : bribe < BIG_BRIBE ? MODEST_BRIBE_SCORE : BIG_BRIBE_SCORE
      "#{chance} on 1d8+#{modifier}".chance
    end

    def petition!(other_character,bribe=0)
      return false unless current_estate && other_character.current_estate
      return false unless other_character.current_estate.id == current_estate.id
      bribe = 0 unless bribe
      bribe = self.noble_house.wealth if bribe > self.noble_house.wealth
      chance = chance_influence(other_character,bribe)
      if chance.success?
        if chance.rolled > (chance.score + PETITION_MAJOR_SUCCESS_DIFFERENCE) # major success
          other_character.decrease_loyalty!(PETITION_MAJOR_SUCCESS)
          add_news!("PETITION_MAJOR_SUCCESS",other_character)
        else
          other_character.decrease_loyalty!(PETITION_MINOR_SUCCESS)
          add_news!("PETITION_SUCCESS",other_character)
        end
      elsif chance.rolled <= PETITION_DISASTER_ROLL && bribe < BIG_BRIBE
        other_character.increase_loyalty!(PETITION_MAJOR_SUCCESS)
        add_news!("PETITION_DISASTER",other_character)
      else
        add_news!("PETITION_FAILED",other_character)
      end
      self.noble_house.subtract_wealth!(bribe)
      other_character.pension = 0 unless other_character.pension
      other_character.pension += bribe
      other_character.save!
      true
    end

    def chance_spy(information_type)
      return 0 unless INFORMATION_TYPES.include?(information_type)
      modifier = sum_skill_modifiers(:research)
      INFORMATION_BASE_CHANCE[information_type] + modifier
    end

    def chance_spy_discovered(information_type)
      return 0 unless INFORMATION_TYPES.include?(information_type)
      INFORMATION_DISCOVERY_CHANCE[information_type]
    end

    def spy!(information_type)
      return false unless INFORMATION_TYPES.include?(information_type)
      return false unless current_estate
      chance = chance_spy(information_type)
      if chance.success?
        add_news!('SPY_SUCCESS')
        send_internal_message!("Confidential Report: Estate #{current_estate.name} - #{information_type}","#{liege.salutation},

          My informants have successfully managed to gain the information concerning the #{information_type.downcase} at Estate #{current_estate.name} as per your request.

          #{prepare_spy_report(information_type)}

          Your humble servant,

          #{self.name}
          ")
      else
        add_news!('SPY_FAIL')
      end
      if chance_spy_discovered(information_type).success?
        DiplomaticRelation.cassus_belli!(current_estate.noble_house, self.noble_house, DiplomaticRelation::ESPIONAGE)
        emissary_discovered!('SPY')
      end
      true
    end

    def prepare_spy_report(information_type)
      report = ''
      case information_type
      when INFORMATION_ARMIES
        report = "The following armies are present at this estate:"
        armies = Army.at(current_estate)
        unless armies.empty?
          report = report + "[ul]\n"
          armies.each do |army|
            report = report + " [*] House #{army.noble_house.name} #{army.name} Army"
            report = report + " led by #{army.legate.display_name}" if army.legate
            report = report + ". "
            unless army.units.empty?
              report = report + "It is composed of the following units: "
              unit_map = army.units.map do |unit|
                unit_line = unit.name
                unit_line = unit_line + " commanded by #{unit.knight.display_name}" if unit.knight
                unless unit.bundles.empty?
                  unit_line = unit_line + " (" + unit.bundles.map{|ib| "#{ib.item.name} x #{ib.quantity}"}.join(",") + ")"
                end
                unit_line
              end
              report = report + unit_map.join(", ")
            end
            report = report + "\n"
          end
          report = report + "[/ul]\n"
        else
          report = report + "\nNo armies present."
        end
      when INFORMATION_SPACESHIPS
        report = "The following starships are present at this estate:"
        starships = Starship.at(current_estate)
        unless starships.empty?
          report = report + "[ul]\n"
          starships.each do |starship|
            report = report + " [*] House #{starship.noble_house.name} - #{starship.name} Ship"
            report = report + " led by #{starship.captain.display_name}" if starship.captain
            report = report + ".\n"
          end
          report = report + "[/ul]\n"
        else
          report = report + "\nNo starships present."
        end
      when INFORMATION_BUILDINGS
        report = "The following buildings are present at this estate:"
        unless current_estate.buildings.empty?
          report = report + "[ul]\n"
          current_estate.buildings.each do |building|
            report = report + " [*] #{building.building_type.category} Level #{building.level}\n"
          end
          report = report + "[/ul]"
        else
          report = report + "\nNo buildings found." 
        end
      when INFORMATION_NON_MILITARY
        report = "The following non-military items are present at this estate:"
        count = 0
        items = "[ul]\n"
        current_estate.bundles.each do |ib|
          unless ib.item.military? || ib.item.troop?
            count += 1
            items = items + " [*] #{ib.quantity} x #{ib.item.name}\n" 
          end
        end
        if count > 0
          report = report + items + "[/ul]\n#{count} items found."
        else
          report = report + "\nNo items found."
        end
      when INFORMATION_MILITARY
        report = "The following military items are present at this estate:"
        count = 0
        items = "[ul]\n"
        current_estate.bundles.each do |ib|
          if ib.item.military? || ib.item.troop?
            count += 1
            items = items + " [*] #{ib.quantity} x #{ib.item.name}\n"
          end
        end
        if count > 0
          report = report + items + "[/ul]\n#{count} items found."
        else
          report = report + "\nNo items found."
        end
      when INFORMATION_PRODUCTION
        report = "The following items will be produced at this estate:"
        unless current_estate.production_queues.empty?
          report = report + "[ul]\n"
          current_estate.production_queues.each do |queue|
            report = report + " [*] #{queue.quantity} x #{queue.item.name}\n"
          end
          report = report + "[/ul]\n"
        else
          report = report + "\nNo production queue."
        end
      end
      report
    end

    def chance_sabotage_building_category(category)
      modifier = sum_skill_modifiers(:sabotage)
      if BuildingType::TRADE_GOOD_BUILDINGS.include?(category) || BuildingType::ORE_BUILDINGS.include?(category)
        return SABOTAGE_ORE_TRADE_GOOD + modifier
      elsif BuildingType::RECRUITMENT_BUILDINGS.include?(category)
        return SABOTAGE_RECRUITMENT_MODULES + modifier
      elsif BuildingType::TRADE_BUILDINGS.include?(category)
        return SABOTAGE_TRADE_NAVAL + modifier
      elsif building.category == BuildingType::PALACE
        return SABOTAGE_PALACE_MILITARY + modifier
      else
        return SABOTAGE_OTHER + modifier
      end
    end

    def chance_sabotage_item_category(category)
      modifier = sum_skill_modifiers(:sabotage)
      if Item::ORE == category || Item::TRADE_GOOD == category
        return SABOTAGE_ORE_TRADE_GOOD + modifier
      elsif Item::MODULE == category
        return SABOTAGE_RECRUITMENT_MODULES + modifier
      elsif Item::NAVAL.include?(category)
        return SABOTAGE_TRADE_NAVAL + modifier
      elsif Item::MILITARY.include?(category)
        return SABOTAGE_PALACE_MILITARY + modifier
      else
        return SABOTAGE_OTHER + modifier
      end
    end

    def chance_sabotage(building,item)
      modifier = sum_skill_modifiers(:sabotage)
      if building
        chance_sabotage_building_category(building.category)
      elsif item
        chance_sabotage_item_category(item.category)
      else
        return 0
      end
    end

    def chance_sabotage_discovered(building,item)
      if building
        if building.trade_good? || building.ore?
          return SABOTAGE_DISCOVERED_ORE_TRADE_GOOD
        elsif building.recruitment?
          return SABOTAGE_DISCOVERED_RECRUITMENT_MODULES
        elsif building.trade_hall? || building.shuttle_capacity > 0 || building.orbital_dock?
          return SABOTAGE_DISCOVERED_TRADE_NAVAL
        elsif building.category == BuildingType::PALACE
          return SABOTAGE_DISCOVERED_PALACE_MILITARY
        else
          return SABOTAGE_DISCOVERED_OTHER
        end
      elsif item
        if item.ore? || item.trade_good?
          return SABOTAGE_DISCOVERED_ORE_TRADE_GOOD
        elsif item.module?
          return SABOTAGE_DISCOVERED_RECRUITMENT_MODULES
        elsif item.naval?
          return SABOTAGE_DISCOVERED_TRADE_NAVAL
        elsif item.military?
          return SABOTAGE_DISCOVERED_PALACE_MILITARY
        else
          return SABOTAGE_DISCOVERED_OTHER
        end
      else
        return 0
      end
    end

    def sabotage!(building,item)
      return false unless building || item
      return false unless current_estate
      chance = chance_sabotage(building,item)
      if building
        if chance.success? && current_estate.demolish!(building,1,true)
          add_news!('SABOTEUR_SUCCESS')
          current_estate.add_news!('SABOTAGE',"a level of #{building.category}")
          send_internal_message!("Confidential Report: Estate #{current_estate.name} - #{building.category}","#{liege.salutation},

            I have successfully managed to plant explosives that have destroyed a level of #{building.category} as per your request.

            Your humble servant,

            #{self.name}
            ")
        else
          add_news!('SABOTEUR_FAILED')
        end
      else
        items_count = current_estate.count_item(item)
        if items_count > 0 && chance.success?
          items_destroyed = rand(items_count) + 1
          current_estate.remove_item!(item, items_destroyed)
          current_estate.add_news!('SABOTAGE',"#{items_destroyed} of #{item.name}")
          add_news!('SABOTEUR_SUCCESS')
          send_internal_message!("Confidential Report: Estate #{current_estate.name} - #{item.name}","#{liege.salutation},

            I can report that #{items_destroyed} of #{item.name} met with an unfortunate accident and have perished at this estate.

            Your humble servant,

            #{self.name}
            ")
        else
          add_news!('SABOTEUR_FAILED')
        end
      end
      if chance_sabotage_discovered(building,item).success?
        DiplomaticRelation.cassus_belli!(current_estate.noble_house, self.noble_house, DiplomaticRelation::ESPIONAGE)
        emissary_discovered!('SABOTEUR')
      end
      true
    end

    def chance_assassinate(other_character)
      modifier = sum_skill_modifiers(:assassination)
      base = nil
      base = ASSASSINATION_NOBLE if other_character.noble?
      base = ASSASSINATION_CHURCH if base.nil? && other_character.church?
      base = ASSASSINATION_OTHER unless base
      base + modifier
    end

    def chance_assassination_discovered(other_character)
      base = nil
      base = ASSASSINATION_DISCOVERED_NOBLE if other_character.noble?
      base = ASSASSINATION_DISCOVERED_CHURCH if base.nil? && other_character.church?
      base = ASSASSINATION_DISCOVERED_OTHER unless base
      base
    end

    def assassinate!(other_character)
      return false unless current_estate
      return false if current_estate != other_character.current_estate
      chance = chance_assassinate(other_character)
      if chance.success?
        add_news!('ASSASSIN_SUCCESS')
        send_internal_message!("Confidential Report: #{other_character.display_name} - Successful","#{liege.salutation},

          I am delighted to report that #{other_character.display_name} will be no further trouble.

          Your humble servant,

          #{self.name}
          ")
        other_character.die!("suspicious circumstances")
        if other_character.noble?
          other_character.add_empire_news!('ASSASSINATED')
        elsif other_character.clergy?
          other_character.add_church_news!('ASSASSINATED')
        else
          other_character.add_news!('ASSASSINATED')
        end
      else
        add_news!('ASSASSIN_FAIL')
      end
      chance = chance_assassination_discovered(other_character)
      if chance.success?
        emissary_discovered!('ASSASSIN')
        DiplomaticRelation.cassus_belli!(other_character.noble_house, self.noble_house, DiplomaticRelation::ASSASSINATION) unless self.same_house?(other_character)
        if self.related?(other_character)
          self.add_trait!(Trait::SPECIAL_KINSLAYER) unless self.dead?
          self.noble_house.baron.add_trait!(Trait::SPECIAL_KINSLAYER)
        end
      end
      true
    end

    def emissary_discovered!(activity)
      add_news!("#{activity}_DISCOVERED",current_estate)
      case "1d6".roll
        when 1
          self.die!("overzealous security forces")
        when 2
          Prisoner.imprison!(self, self.location)
          self.add_trait!(Trait::SPECIAL_INJURED)
        when 3
          Prisoner.imprison!(self, self.location)
          self.add_trait!(Trait::SPECIAL_WOUNDED)
        else
          move_to_nearest_estate!
      end
    end

  end
end
