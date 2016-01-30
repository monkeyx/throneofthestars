class GroundBattle < ActiveRecord::Base
  attr_accessible :attacker_id, :attacker, :attacker_type, :battle_date, :battle_status, :defender_id, :defender, :defender_type, :location, :location_id, :location_type, :report

  include Locatable

  game_date :battle_date
  
  DEFENDER_WON = "Defender Won"
  ATTACKER_WON = "Attacker Won"
  DRAW = "Battle Drawn"

  attr_accessor :defender_report_from, :attacker_report_from, :report_subject

  def attacker
    return nil if self.attacker_type.blank? || attacker_id == 0
    k = Kernel.const_get(self.attacker_type)
    begin
      return k.find(attacker_id)
    rescue
      self.attacker_id = 0
      self.attacker_type = nil
      save
      return nil
    end
  end
  def attacker=(l)
    if l.nil?
      self.attacker_type = nil
      self.attacker_id = 0
    else
      self.attacker_type = l.class.to_s
      self.attacker_id = l.id
    end
  end

  def defender
    return nil if self.defender_type.blank? || defender_id == 0
    k = Kernel.const_get(self.defender_type)
    begin
      return k.find(defender_id)
    rescue
      self.defender_id = 0
      self.defender_type = nil
      save
      return nil
    end
  end
  def defender=(l)
    if l.nil?
      self.defender_type = nil
      self.defender_id = 0
    else
      self.defender_type = l.class.to_s
      self.defender_id = l.id
    end
  end

  def ship_boarding?
    attacker.is_a?(Starship)
  end

  def self.fight!(attacker,defender,date=Game.current_date)
    return false unless attacker && defender
    if defender.is_a?(Army)
      return false unless defender.same_location?(attacker)
      return false unless defender.current_region
      return false if defender.current_region.current_season == Region::WINTER
    end
    if defender.is_a?(Estate)
      return false unless attacker.at_same_estate?(defender)
      return false if defender.region.current_season == Region::WINTER
    end
    if attacker.is_a?(Starship)
      return false unless attacker.orbiting?
      return false unless defender.is_a?(Starship)
      return false unless attacker.faster?(defender)
    end
    if attacker.is_a?(Starship)
      unless attacker.noble_house.at_war?(defender.noble_house)
        alliance = attacker.noble_house.current_alliance(defender.noble_house)
        attacker.noble_house.break_alliance!(defender.noble_house,true) if alliance
        DiplomaticRelation.cassus_belli!(defender.noble_house,attacker.noble_house,DiplomaticRelation::ATTACK_HOUSE)
        if defender.noble_house.liege
          DiplomaticRelation.cassus_belli!(defender.noble_house.liege,attacker.noble_house,DiplomaticRelation::ATTACK_VASSAL) 
        end
        defender.noble_house.allies.each do |ally|
          DiplomaticRelation.cassus_belli!(ally,attacker.noble_house,DiplomaticRelation::ATTACK_ALLY) 
        end
        if Law.piracy_outlaws?
          NobleHouse.active.each do |house|
            DiplomaticRelation.cassus_belli!(house,attacker.noble_house,DiplomaticRelation::PIRACY) 
          end
        end
      end
    end
    battle = create!(:attacker => attacker, :defender => defender, :battle_date => date, :location => attacker.location, :report => '')
    transaction do
      battle.resolve!
      battle.save
      news_target = "#{attacker.name} versus #{defender.name}"
      case battle.battle_status
      when ATTACKER_WON
        attacker.noble_house.add_empire_news!('GROUND_BATTLE_WON',news_target)
        defender.noble_house.add_news!('GROUND_BATTLE_LOST',news_target)
      when DEFENDER_WON
        attacker.noble_house.add_empire_news!('GROUND_BATTLE_LOST',news_target)
        defender.noble_house.add_news!('GROUND_BATTLE_WON',news_target)
      when DRAW
        attacker.noble_house.add_news!('GROUND_BATTLE_DRAW',news_target)
        defender.noble_house.add_news!('GROUND_BATTLE_DRAW',news_target)
      end
    end
    battle
  end

  def leader(position)
    leader = nil
    leader = position.legate if position.is_a?(Army)
    leader = position.lord if position.is_a?(Estate)
    leader = position.captain if position.is_a?(Starship)
    leader = position.noble_house.baron unless leader
    leader
  end

  def resolve!
    @defender_report_from = leader(defender)
    @attacker_report_from = leader(attacker)
    @total_attacker_damage = 0
    @total_defender_damage = 0
    @attacker_total_troops = troops(attacker).sum{|ib| ib.quantity}
    @defender_total_troops = troops(defender).sum{|ib| ib.quantity}

    report_top
    unless ship_boarding?
      air_supremacy_phase!    
      strategic_phase!
    end
    (1..4).each do |round|
      tactical_round!(round)
      return finish_fight if end_of_battle?
    end
    finish_fight
  end

  def finish_fight
    determine_status
    @defender_glory = @total_attacker_damage
    @attacker_glory = @total_defender_damage
    if battle_status == DEFENDER_WON
      @defender_glory = (@defender_glory * 0.02).round(0).to_i
      @attacker_glory = (@attacker_glory * 0.005).round(0).to_i
    elsif battle_status == ATTACKER_WON
      @attacker_glory = (@attacker_glory * 0.02).round(0).to_i
      @defender_glory = (@defender_glory * 0.005).round(0).to_i
    else
      @defender_glory = (@defender_glory * 0.01).round(0).to_i
      @attacker_glory = (@attacker_glory * 0.01).round(0).to_i
    end
    leader(attacker).add_glory!(@attacker_glory)
    leader(defender).add_glory!(@defender_glory)
    check_for_death_and_injuries(attacker) if @total_attacker_damage > 0
    check_for_death_and_injuries(defender) if @total_defender_damage > 0

    add_headline "Battle Resolution"
    add_line

    if attacker.is_a?(Army)
      attacker_troops_lost = ((@attacker_total_troops.to_f - troops(attacker).sum{|ib| ib.quantity}) / @attacker_total_troops.to_f) * 100.0 if @attacker_total_troops > 0
      test_morale(attacker, attacker_troops_lost)
      if battle_status == ATTACKER_WON
        add_line "#{attacker.name} morale improved because of the victory"
        attacker.morale = attacker.morale + 25 
        attacker.save
      end
    end
    if defender.is_a?(Army)
      defender_troops_lost = ((@defender_total_troops.to_f - troops(defender).sum{|ib| ib.quantity}) / @defender_total_troops.to_f) * 100.0 if @defender_total_troops > 0
      test_morale(defender, defender_troops_lost)
      if battle_status == DEFENDER_WON
        add_line "#{defender.name} morale improved because of the victory"
        defender.morale = defender.morale + 25 
        defender.save
      end
    end

    troop_promotions(attacker) unless lost?(attacker)
    troop_promotions(defender) unless lost?(defender)

    Character.at(attacker).each do |c|
      if c.alive?
        exp,skill = c.ground_combat_experience!
        if exp > 0
          add_line "#{c.display_name} learned something about #{skill.category}"
        end
      end
    end

    Character.at(defender).each do |c|
      if c.alive?
        exp,skill = c.ground_combat_experience!
        if exp > 0
          add_line "#{c.display_name} learned something about #{skill.category}"
        end
      end
    end

    if lost?(defender) && (defender.is_a?(Starship) || defender.is_a?(Estate))
      defender.add_empire_news!('CAPTURED',attacker.noble_house)
      if defender.is_a?(Estate)
        Character.at(defender).each do |c|
          if c.noble_house_id == defender.noble_house_id
            unless c.tribune? || c.steward?
              Prisoner.imprison!(c,defender,true) 
              add_line "#{c.display_name} was captured and imprisoned"
            end
          end
        end
        Title.belonging_to(defender.lord).title(Title::LORD).estate(defender).first.revoke!
        attacker.noble_house.baron.add_title!(Title::LORD,defender)
      end
      if defender.is_a?(Starship)
        Character.at(defender).each{|c| c.move_to_nearest_estate!}
        unless defender.has_bridge?
          defender.breakdown!
          attacker.salvage!(defender)
        else
          unless attacker.crew.empty?
            new_captain = attacker.crew.sample
            add_line "#{new_captain.display_name} took over command of #{defender.name}"
            defender.embark_character!(new_captain)
          end
        end
      end
      # add_line "House #{old_house.name} previously had #{estates.size} estates"
      defender.update_attributes!(:noble_house_id => attacker.noble_house_id)
      add_line "[b]#{attacker.name} captured #{defender.name}![/b]"
      old_house = defender.noble_house
      estates = Estate.of(old_house)
      if defender.is_a?(Estate)
        estates = Estate.of(old_house)
        if estates.empty?
          old_house.cease! 
          add_line "[b]House #{old_house.name} was annihilated![/b]"
        else
          estates_remaining = estates.size
          add_line "House #{old_house.name} has #{estates_remaining} #{(estates_remaining == 1 ? 'estate' : 'estates')} remaining"
        end
      end
    end

    report_bottom
    unless defender.noble_house.ancient? || defender_report_from.nil?
      defender_report_from.send_internal_message!(report_subject,self.report)
    end
    unless attacker.noble_house.ancient? || attacker_report_from.nil?
      attacker_report_from.send_internal_message!(report_subject,self.report)
    end
  end

  def test_morale(army,percentage_lost)
    percentage_lost = 0 unless percentage_lost
    roll = "1d100".roll
    if roll >= (army.effective_morale - percentage_lost)
      army.morale = army.morale - 25
      army.save
      add_line "#{army.name} morale broke"
      troops(army).each do |ib|
        qty = (ib.quantity * 0.25).round(0).to_i
        if qty > 0
          add_line "#{army.name} lost #{qty} x #{ib.item.name} due to desertion" 
          ib.quantity = ib.quantity - qty
          ib.save
        end
      end
    end
  end

  def troop_promotions(position)
    unless position.is_a?(Starship)
      soldiers(position).each do |ib|
        roll = "1d6+1".roll
        qty = (ib.quantity * (roll * 0.01)).round(0).to_i
        if qty > 0
          ib.quantity = ib.quantity - qty
          ib.save
          add_line "#{position.name} had #{qty} x Soldier promoted to Marine"
          if position.is_a?(Army)
            position.create_unit!("Field Promotions",Item.find_by_name('Marine'),qty)
          elsif position.is_a?(Estate)
            position.add_item!(Item.find_by_name('Marine'),qty)
          else
            raise "Invalid position type!"
          end
        end
      end
    end
    marines(position).each do |ib|
      roll = "1d4-1".roll
      qty = (ib.quantity * (roll * 0.01)).round(0).to_i
      if qty > 0
        ib.quantity = ib.quantity - qty
        ib.save
        add_line "#{position.name} had #{qty} x Marine promoted to Vanguard"
        if position.is_a?(Army)
          position.create_unit!("Field Promotions",Item.find_by_name('Vanguard'),qty)
        elsif position.is_a?(Estate) || position.is_a?(Starship)
          position.add_item!(Item.find_by_name('Vanguard'),qty)
        else
          raise "Invalid position type!"
        end
      end
    end
  end

  def items_by_type(position,categories)
    if position.is_a?(Army)
      bundles = []
      position.units.each do |unit|
        bundles = bundles + ItemBundle.at(unit).types(categories)
      end
      return bundles
    else
      return ItemBundle.at(position).types(categories)
    end
  end

  def aircraft(position)
    items_by_type(position,[Item::AIRCRAFT]).select{|ib| ib.item.air_supremacy }
  end

  def damage_takers(position)
    list = position.is_a?(Starship) ? marines(position) : tactical(position)
    list.sort{|a,b| (b.item.ground_armour_save ? b.item.ground_armour_save.probability_of_success : 0) <=> (a.item.ground_armour_save ? a.item.ground_armour_save.probability_of_success : 0) }
  end

  def strategic(position)
    items_by_type(position,[Item::AIRCRAFT,Item::ORDINANCE]).select{|ib| ib.item.strategic_to_hit }
  end

  def tactical(position)
    items_by_type(position,[Item::TROOP,Item::TANK,Item::ORDINANCE, Item::AIRCRAFT]).select{|ib| ib.item.tactical_to_hit }
  end

  def troops(position)
    items_by_type(position,[Item::TROOP])
  end

  def marines(position)
    marine = Item.find_by_name('Marine')
    if position.is_a?(Army)
      bundles = []
      position.units.each do |unit|
        bundles = bundles + ItemBundle.at(unit).of(marine)
      end
      return bundles
    else
      return ItemBundle.at(position).of(marine)
    end
  end

  def soldiers(position)
    soldier = Item.find_by_name('Soldier')
    if position.is_a?(Army)
      bundles = []
      position.units.each do |unit|
        bundles = bundles + ItemBundle.at(unit).of(soldier)
      end
      return bundles
    else
      return ItemBundle.at(position).of(soldier)
    end
  end

  def calculated_aircraft_destroyed(aircraft)
    d = 0
    aircraft.each do |ib|
      (1..(ib.quantity)).each do
        d += 1 if ib.item.air_supremacy.success?
      end
    end
    d
  end

  def allocate_aircraft_destroyed(aircraft, quantity)
    total = aircraft.sum{|ib| ib.quantity }
    if quantity >= total
      aircraft.each{|ib| ib.destroy }
    else
      aircraft.each do |ib|
        q = ib.quantity
        q = quantity if q > quantity
        quantity -= q
        ib.quantity = ib.quantity - q
        ib.quantity < 1 ? ib.destroy : ib.save
        return if quantity < 1
      end
    end
  end

  def air_supremacy_phase!
    defender_aircraft = aircraft(defender)
    attacker_aircraft = aircraft(attacker)
    return false if defender_aircraft.empty? || attacker_aircraft.empty?
    report_start_phase("Air Supremacy",attacker_aircraft,defender_aircraft)

    attacker_aircraft_total = attacker_aircraft.sum{|ib| ib.quantity }
    defender_aircraft_total = defender_aircraft.sum{|ib| ib.quantity }

    (1..4).each do
      attacker_aircraft_destroyed = calculated_aircraft_destroyed(defender_aircraft)
      attacker_aircraft_destroyed = attacker_aircraft_total if attacker_aircraft_total < attacker_aircraft_destroyed
      defender_aircraft_destroyed = calculated_aircraft_destroyed(attacker_aircraft)
      defender_aircraft_destroyed = defender_aircraft_total if defender_aircraft_total < defender_aircraft_destroyed
      allocate_aircraft_destroyed(defender_aircraft, defender_aircraft_destroyed)
      allocate_aircraft_destroyed(attacker_aircraft, attacker_aircraft_destroyed)
      add_list_item "#{attacker.name} destroyed #{defender_aircraft_destroyed} enemy aircraft" if defender_aircraft_destroyed > 0
      add_list_item "#{defender.name} destroyed #{attacker_aircraft_destroyed} enemy aircraft" if attacker_aircraft_destroyed > 0
      defender_aircraft = aircraft(defender)
      attacker_aircraft = aircraft(attacker)
      attacker_aircraft_total = attacker_aircraft.sum{|ib| ib.quantity }
      defender_aircraft_total = defender_aircraft.sum{|ib| ib.quantity }
    end
    end_list
  end

  def calculate_hits(quantity,chance,damage,hits = {})
    (1..quantity).each do 
      if chance.success?
        qty = hits[damage]
        qty = 0 unless qty
        qty += 1
        hits[damage] = qty
      end
    end
    hits
  end

  def allocate_damage(position,hits,armour_save_modifier)
    damage_taken = {}
    damage_carried = 0
    hits.keys.sort{|a,b| b.average <=> a.average}.each do |damage|
      (1..hits[damage]).each do
        takers = damage_takers(position)
        return damage_taken if takers.empty?
        unless takers[0].item.ground_armour_save && (takers[0].item.ground_armour_save + armour_save_modifier).success?
          damage_carried += damage.roll
          if damage_carried >= takers[0].item.hit_points
            qty = damage_taken[takers[0].item]
            qty = 0 unless qty
            qty += 1
            damage_taken[takers[0].item] = qty
            takers[0].quantity = takers[0].quantity - 1
            damage_carried -= takers[0].item.hit_points
            takers[0].quantity > 0 ? takers[0].save : takers[0].destroy
          end
        end
      end
    end
    damage_taken
  end

  def fight_round(strategic, attacker_items, defender_items,accuracy_modifiers,armour_save_modifiers)
    attacker_hits = {}
    defender_hits = {}

    if strategic
      defender_items.each{|ib| attacker_hits = calculate_hits(ib.quantity,ib.item.strategic_to_hit + accuracy_modifiers[0],ib.item.strategic_damage,attacker_hits)}
      attacker_items.each{|ib| defender_hits = calculate_hits(ib.quantity,ib.item.strategic_to_hit + accuracy_modifiers[1],ib.item.strategic_damage,defender_hits)}
    else
      defender_items.each{|ib| attacker_hits = calculate_hits(ib.quantity,ib.item.tactical_to_hit + accuracy_modifiers[0],ib.item.tactical_damage,attacker_hits)}
      attacker_items.each{|ib| defender_hits = calculate_hits(ib.quantity,ib.item.tactical_to_hit + accuracy_modifiers[1],ib.item.tactical_damage,defender_hits)}
    end
    defender_damage_taken = allocate_damage(defender,defender_hits,armour_save_modifiers[0])
    attacker_damage_taken = allocate_damage(attacker,attacker_hits,armour_save_modifiers[1])

    defender_damage_taken.keys.each do |item|
      add_list_item "#{attacker.name} destroyed #{defender_damage_taken[item]} x #{item.name}" if defender_damage_taken[item] > 0
      @total_defender_damage = @total_defender_damage + (defender_damage_taken[item] * item.mass)
    end

    attacker_damage_taken.keys.each do |item|
      add_list_item "#{defender.name} destroyed #{attacker_damage_taken[item]} x #{item.name}" if attacker_damage_taken[item] > 0
      @total_attacker_damage = @total_attacker_damage + (attacker_damage_taken[item] * item.mass)
    end
  end

  def armour_save_modifiers
    [(defender.effective_fortification - attacker.effective_explosives),(attacker.effective_fortification - defender.effective_explosives)]
  end

  def strategic_phase!
    defender_strategic = strategic(defender)
    attacker_strategic = strategic(attacker)
    return false if defender_strategic.empty? && attacker_strategic.empty?
    accuracy_modifiers = [defender.effective_reconnaissance, attacker.effective_reconnaissance]
    report_start_phase("Strategic",attacker_strategic,defender_strategic)
    fight_round(true, attacker_strategic, defender_strategic,accuracy_modifiers,armour_save_modifiers)
    end_list
  end

  def tactical_round!(round)
    if attacker.is_a?(Starship)
      defender_tactical = marines(defender)
      attacker_tactical = marines(attacker)
    else
      defender_tactical = tactical(defender)
      attacker_tactical = tactical(attacker)
    end
    return false if defender_tactical.empty? || attacker_tactical.empty?
    accuracy_modifiers = [defender.effective_tactics, attacker.effective_tactics]
    report_start_phase("Tactical",attacker_tactical,defender_tactical,round)
    fight_round(false, attacker_tactical, defender_tactical,accuracy_modifiers,armour_save_modifiers)
    end_list
  end

  def attacker_lost?
    lost?(attacker)
  end

  def lost?(position)
    position.is_a?(Starship) ? marines(position).empty? : troops(position).empty?
  end

  def end_of_battle?
    lost?(defender) || lost?(attacker)
  end

  def check_for_death_and_injuries(position)
    modifier = 0 - position.effective_medicine
    subheading = position.id == defender.id ? "Defender" : "Attacker"
    some_injuries = false
    add_headline("#{subheading} Character Injuries (Injury Roll Modifier: #{modifier})")
    start_list
    Character.at(position).each do |c|
      injury_roll = "1d10".roll + modifier
      if injury_roll >= 10
        add_list_item "#{c.display_name} was killed."
        c.die!("a battle") 
        some_injuries = true
      elsif injury_roll >= 9
        add_list_item "#{c.display_name} was wounded."
        c.add_trait!(Trait::SPECIAL_WOUNDED)
        some_injuries = true
      elsif injury_roll >= 8
        add_list_item "#{c.display_name} was badly hurt."
        c.add_trait!(Trait::SPECIAL_INJURED)
        some_injuries = true
      end
    end
    unless some_injuries
      add_list_item "No injuries during the battle" 
    end
    end_list
  end

  def report_subject
    @report_subject ||= "Ground Battle: #{self.location.name}"
  end

  def report_top
    add_headline("Attacker: #{attacker.name} (#{attacker.class.name})")
    add_line
    add_headline("Defender: #{defender.name} (#{defender.class.name})")
    add_line
  end

  def report_start_phase(phase,attacker_items,defender_items,round=nil)
    r = round ? " Round #{round}" : ''
    add_headline "#{phase} Phase#{r}"
    report_items(attacker, attacker_items)
    report_items(defender, defender_items)
    add_line "Results:"
    start_list
  end

  def report_items(position, items)
    add_line "#{position.name}:"
    start_list
    items.each do |ib|
      add_list_item "#{ib.quantity} x #{ib.item.name}"
    end
    end_list
  end

  def status_report(position)
    return "Defeated" if lost?(position)
    "Survives"
  end

  def report_bottom
    add_line
    add_headline battle_status
    add_line
    add_line "Attacker: #{attacker.name} - #{status_report(attacker)}"
    add_line "Defender: #{defender.name} - #{status_report(defender)}"
    add_line
    add_line "[b]House #{attacker.noble_house.name} gained #{@attacker_glory} glory[/b]" if @attacker_glory > 0
    add_line "[b]House #{defender.noble_house.name} gained #{@defender_glory} glory[/b]" if @defender_glory > 0
    add_line
    add_headline "End of Battle"
  end

  def determine_status
    if lost?(defender) && !lost?(attacker)
     self.battle_status = ATTACKER_WON 
    elsif lost?(attacker) && !lost?(defender)
     self.battle_status = DEFENDER_WON 
    else
      self.battle_status = DRAW 
    end
  end

  def add_headline(s)
    #Kernel.p "*** #{s} ***"
    self.report = self.report + "[b]*** #{s} ***[/b]"
    add_line
  end

  def add_line(line='')
    #Kernel.p line
    self.report = self.report + line + "\n"
  end

  def start_list
    self.report = self.report + "[ul]"
  end

  def add_list_item(item)
    #Kernel.p "* #{item}"
    self.report = self.report + " [*] #{item}\n"
  end

  def end_list
    self.report = self.report + "[/ul]"
  end

end
