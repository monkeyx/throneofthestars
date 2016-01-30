class SpaceBattle < ActiveRecord::Base
  attr_accessible :attacker, :attacker_id, :battle_date, :defender, :defender_id, :location, :location_id, :location_type, :report, :battle_status

  belongs_to :attacker, :class_name => 'Starship'
  belongs_to :defender, :class_name => 'Starship'

  include Locatable

  game_date :battle_date

  attr_accessor :speeds, :defender_report_from, :attacker_report_from, :report_subject

  DEFENDER_WON = "Defender Won"
  ATTACKER_WON = "Attacker Won"
  DRAW = "Battle Drawn"

 def self.fight!(attacker,defender,date=Game.current_date)
  	return false unless attacker && defender && defender.location_type == 'World' && attacker.orbiting?(defender.location)
  	battle = create!(:attacker => attacker, :defender => defender, :battle_date => date, :location => attacker.location, :report => '')
  	transaction do
		  battle.resolve!
	    battle.save
      news_target = "#{attacker.name} versus #{defender.name}"
      case battle.battle_status
      when ATTACKER_WON
        attacker.noble_house.add_empire_news!('SPACE_BATTLE_WON',news_target)
        defender.noble_house.add_news!('SPACE_BATTLE_LOST',news_target)
      when DEFENDER_WON
        attacker.noble_house.add_empire_news!('SPACE_BATTLE_LOST',news_target)
        defender.noble_house.add_news!('SPACE_BATTLE_WON',news_target)
      when DRAW
        attacker.noble_house.add_news!('SPACE_BATTLE_DRAW',news_target)
        defender.noble_house.add_news!('SPACE_BATTLE_DRAW',news_target)
      end
	  end
    battle
  end

  def resolve!
  	@speeds = {attacker_id => self.attacker.ship_speed, self.defender_id => defender.ship_speed }
    @defender_report_from = self.defender.captain
    @attacker_report_from = self.attacker.captain
    @total_attacker_damage = 0
    @total_defender_damage = 0

  	report_top
  	(1..4).each do |round|
  		fight_round(round)
      return finish_fight if end_of_battle?
  	end
    finish_fight
  end

  def finish_fight
    determine_status
    @defender_glory = @total_attacker_damage > attacker.max_hull_points ? attacker.max_hull_points : @total_attacker_damage
    @attacker_glory = @total_defender_damage > defender.max_hull_points ? defender.max_hull_points : @total_defender_damage   
    if battle_status == DEFENDER_WON
      @defender_glory = @defender_glory * 2
      @attacker_glory = (@attacker_glory * 0.5).round(0).to_i
    elsif battle_status == ATTACKER_WON
      @attacker_glory = @attacker_glory * 2
      @defender_glory = (@defender_glory * 0.5).round(0).to_i
    end
    attacker.captain.add_glory!(@attacker_glory) if attacker.captain
    defender.captain.add_glory!(@defender_glory) if defender.captain
    check_for_death_and_injuries(attacker) if @total_attacker_damage > 0
    check_for_death_and_injuries(defender) if @total_defender_damage > 0

    total_exp = 0

    Character.at(attacker).each do |c|
      if c.alive?
        exp,skill = c.space_combat_experience!
        if exp > 0
          add_line "#{c.display_name} learned something about #{skill.category}"
          total_exp += exp
        end
      end
    end

    Character.at(defender).each do |c|
      if c.alive?
        exp,skill = c.space_combat_experience!
        if exp > 0
          add_line "#{c.display_name} learned something about #{skill.category}"
          total_exp += exp
        end
      end
    end

    add_line unless total_exp == 0

    report_bottom
    unless defender.noble_house.ancient? || defender_report_from.nil?
      defender_report_from.send_internal_message!(report_subject,self.report)
    end
    unless attacker.noble_house.ancient? || attacker_report_from.nil?
      attacker_report_from.send_internal_message!(report_subject,self.report)
    end
  end

  def fight_round(round)
  	report_start_round(round)
    Item::WEAPON_SPEEDS[0..2].each do |weapon_speed|
      return end_list if end_of_battle?
      attacker.reload
      defender.reload
  		@attacker_damage = 0
  		@defender_damage = 0
      attacker.weapons_by_speed(weapon_speed).each do |weapon_section|
  			@defender_damage += fire(attacker, weapon_section, defender)
  		end
  		defender.weapons_by_speed(weapon_speed).each do |weapon_section|
  			@attacker_damage += fire(defender, weapon_section, attacker)
  		end
  		allocate_hull_damage(defender,@defender_damage)
  		allocate_hull_damage(attacker, @attacker_damage)
      @total_defender_damage += @defender_damage
      @total_attacker_damage += @attacker_damage
  	end
  	end_list
  end

  def fire(ship, weapon_section, target)
    raise "No ship specified" unless ship
    raise "No target specified" unless target
    raise "Firing nothing" unless weapon_section
  	weapon = weapon_section.item
    raise "Weapon Section #{weapon_section.id} has no item" unless weapon
  	quantity = weapon_section.quantity
    raise "Weapon Section #{weapon_section.id} has no quantity" unless quantity
  	hits = 0
  	total_damage = 0
  	saved = 0
  	ammo_used = []
  	best_defense = target.best_defense(weapon,speeds[target.id])
  	best_save = target.best_save_chance(weapon)
    launched_drones = {}
    @internal_damage = ''

    # Kernel.p "FIRING: #{weapon.name} at #{target.name} - Defense: #{best_defense} (#{best_save})"
  	(1..quantity).each do 
  		if weapon.reduce_speed
        no_damage, qty_hit = shoot_weapon(ship,weapon,0)
  			reduce_speed(target) if qty_hit > 0
  		elsif weapon.lifeform_damage && weapon.lifeform_damage > 0
        damage, hit = shoot_weapon(ship,weapon,0)
        check_for_death_and_injuries(ship,weapon.lifeform_damage) if hit > 0
      elsif weapon.drone_launcher?
        drones, damage, qty_hit = launch_drones(ship, weapon)
        drones.each do |d|
          launched = launched_drones[d[:drone]]
          launched = 0 unless launched
          launched += d[:quantity]
          launched_drones[d[:drone]] = launched
        end
      elsif weapon.launcher?
	  		ammo, damage, qty_hit = shoot_launcher(ship,weapon) 
        ammo_used << ammo
	  	else
	  		damage, qty_hit = shoot_weapon(ship,weapon)
	  	end
	  	if qty_hit && qty_hit > 0
	  		hits += qty_hit
	  		if best_save.success?
	  			saved += 1
	  		else
          internal_damage_check(target,weapon_section.item.internal_damage)
		  		total_damage += damage if damage
	  		end
	  	end
	 end
	 report_weapon(ship, weapon, ammo_used, launched_drones, target, quantity, hits, total_damage, best_defense, saved)
   return_drones(ship,launched_drones) unless launched_drones.empty?
	 total_damage
  end

  def launch_drones(ship,weapon)
    qty_launched = 0
    drones = ship.drones
    return [], 0 if drones.nil? || drones.empty?
    launch = []
    hits = 0
    damage = 0
    drones.each do |ib|
      to_launch = 4 - qty_launched
      to_launch = ib.quantity if ib.quantity < to_launch
      if to_launch > 0
        launch << {:drone => ib.item, :quantity => to_launch}
        qty_launched += to_launch
        d, h = shoot_weapon(ship,weapon,ib.item.damage,to_launch)
        damage += d
        hits += h
      end
      return launch, damage, hits if qty_launched == 4
    end
    return launch, damage, hits
  end

  def return_drones(ship,drones)
    drones.keys.each do |drone|
      destroyed = 0
      (1..drones[drone]).each do
        destroyed += 1 if drone.shot_down.success?
      end
      if destroyed > 0
        ship.remove_item!(drone,destroyed)
        if destroyed == 1
          add_list_item "#{ship.name} lost a #{drone.name} drone." 
        else
          add_list_item "#{ship.name} had #{destroyed} of its #{drone.name} drones destroyed." 
        end
      end
    end
  end

  def shoot_launcher(ship,weapon)
  	ammo_used = nil
  	ammo = ship.ammo_for(weapon)
  	unless ammo.nil? || ammo.empty?
  		ammo_used = ammo.first.item
  		ship.remove_item!(ammo_used,1)
  		return [ammo_used] + shoot_weapon(ship,weapon,ammo_used.damage)
  	end
  	return nil, 0, 0
  end

  def shoot_weapon(ship,weapon,damage=weapon.damage,shots_per_weapon=1)
  	accuracy_modifier = ship.metrics[:accuracy_modifier]
    dmg = 0
    hits = 0
    (1..shots_per_weapon).each do 
      if (weapon.accuracy + accuracy_modifier).success?
  	   dmg += damage.roll if damage.is_a?(Dice)
       hits += 1
     end
    end
  	return dmg, hits
  end

  def reduce_speed(ship)
  	current_rank = Starships::SPEED_RANK[speeds[ship.id]]
  	if current_rank > 1
  		speeds[ship.id] = Starships::SPEED_AT_RANK[(current_rank - 1)]
      report_slowdown(ship,Starships::SPEED[speeds[ship.id]].downcase)
  	end
  end

  def allocate_hull_damage(ship,damage)
    broken, exploded = ship.allocate_damage!(damage)
  	report_explosion(ship) if exploded
  	report_breakdown(ship) if broken
    ship
  end

  def internal_damage_check(ship,weapon_modifier)
    ship.reload
    int_modifier = ((100 - ship.hull_integrity) / 10.0).round(0).to_i
    modifier = weapon_modifier - ship.effective_damage_control + int_modifier
    rolled = "1d10".roll
    #add_list_item "Internal Damage Check - Modifier Weapon #{weapon_modifier} Damage Control #{ship.effective_damage_control} Integrity #{int_modifier} Total #{modifier} - Rolled: #{rolled}"
    rolled += modifier
    if rolled >= 4
      allocate_internal_damage(ship, 'Armour')
    end
    if rolled >= 5
      allocate_internal_damage(ship, 'Ores')
    end
    if rolled >= 6
      allocate_internal_damage(ship, 'Cargo')
    end
    if rolled >= 8
      allocate_internal_damage(ship, 'Primary')
    end
    if rolled >= 10
      allocate_internal_damage(ship, 'Lifeform')
    end
    if rolled >= 12
      rand(100) > 50 ? allocate_internal_damage(ship, 'Mission') : allocate_internal_damage(ship, 'Utility')
    end
    if rolled >= 14
      rand(100) > 50 ? allocate_internal_damage(ship, 'Engine') : allocate_internal_damage(ship, 'Spinal')
    end
    if rolled >= 16
      allocate_internal_damage(ship, 'Command')
    end
  end

  def allocate_internal_damage(ship, internal)
    # self.report = self.report + " [*] Damage to be allocated to #{internal} of #{ship.name}"
  	case internal
  	when 'Armour'
  		quantity_destroy = "1d8".roll
      #add_list_item "#{quantity_destroy} armour to be destroyed"
  		ship.armour_sections.each do |section|
        #add_list_item "Found #{section.quantity} of #{section.item.name}"
  			quantity_destroy = quantity_destroy - destroy_section(ship, section,quantity_destroy)
  			return if quantity_destroy < 1
  		end
  	when 'Command'
  		destroy_section(ship, ship.command_sections.to_a.sample)
  	when 'Mission'
  		destroy_section(ship, ship.mission_sections.to_a.sample)
  	when 'Engine'
  		destroy_section(ship, ship.engine_sections.to_a.sample)
  	when 'Utility'
  		destroy_section(ship, ship.utility_sections.to_a.sample)
  	when 'Primary'
  		destroy_section(ship, ship.primary_sections.to_a.sample)
  	when 'Spinal'
  		destroy_section(ship, ship.spinal_sections.to_a.sample)
  	when 'Cargo'
  		ship.bundles.each do |ib|
  			unless ib.item.lifeform? || ib.item.ore? || ib.item.ammo?
  				qty_destroyed = (("1d10".roll * 0.01) * ib.quantity).round(0).to_i
          if qty_destroyed > 0
    				ship.remove_item!(ib.item,qty_destroyed)
    				report_internal_damage(ship, ib.item, qty_destroyed)
          end
  			end
  		end
  	when 'Lifeform'
  		qty_destroyed = "1d20".roll
  		ship.bundles.each do |ib|
  			if ib.item.lifeform?
  				if qty_destroyed > ib.quantity
  					qty_destroyed = qty_destroyed - ib.quantity
  					ship.remove_item!(ib.item,ib.quantity)
  					report_internal_damage(ship, ib.item, ib.quantity)
  				else
  					ship.remove_item!(ib.item,qty_destroyed)
  					ship.remove_item!(ib.item,qty_destroyed)
  					report_internal_damage(ship, ib.item, qty_destroyed)
  					return
  				end
  			end
  		end
  	when 'Ores'
  		ship.bundles.each do |ib|
  			if ib.item.ore?
          qty_destroyed = (("1d6".roll * 0.01) * ib.quantity).round(0).to_i
          if qty_destroyed > 0
  				  ship.remove_item!(ib.item,qty_destroyed)
  				  report_internal_damage(ship, ib.item, qty_destroyed)
          end
  			end
  		end
  	end
  end

  def destroy_section(ship, section, quantity=1)
  	return 0 unless section && quantity > 0
    quantity = section.quantity if quantity > section.quantity
    #add_list_item "#{ship.name} to lose #{quantity} of #{section.item.name}"
  	report_internal_damage(ship, section.item, quantity)
  	section.quantity = section.quantity - quantity
    if section.quantity < 1
      section.destroy
    else
      section.save
    end
    ship.reload
    quantity
  end

  def check_for_death_and_injuries(ship,weapon_modifier=0)
  	modifier = (((100 - ship.hull_integrity.to_f) / 10.0) - (ship.effective_medicine * 10)).to_i + weapon_modifier
  	subheading = ship.id == defender.id ? "Defender" : "Attacker"
    unless weapon_modifier > 0
      add_headline("#{subheading} Character Injuries (Injury Roll Modifier: #{modifier})")
      start_list
    end
    some_injuries = false
  	Character.at(ship).each do |c|
  		if !ship.has_bridge?
        if ship.has_escape_pods?
          add_list_item "#{c.display_name} was killed because the bridge was destroyed."
  			  c.die!("a space battle") 
        else
          add_list_item "#{c.display_name} escaped after the bridge was destroyed."
          c.move_to_nearest_estate!
        end
  		else
        injury_roll = ("1d10".roll * 10) + modifier
        if injury_roll + modifier >= 100
          desc = weapon_modifier > 0 ? "by the use of the inhumane weapon" : "during the fighting"
          add_list_item "#{c.display_name} was killed #{desc}."
          c.die!("a space battle") 
          some_injuries = true
        elsif injury_roll + modifier >= 90
          desc = weapon_modifier > 0 ? "suffered severe internal hemorrhaging" : "was greviously wounded"
          add_list_item "#{c.display_name} #{desc}."
          c.add_trait!(Trait::SPECIAL_WOUNDED)
          some_injuries = true
        elsif injury_roll + modifier >= 80
          desc = weapon_modifier > 0 ? "burnt badly" : "injured in the chaos"
          add_list_item "#{c.display_name} was #{desc}."
          c.add_trait!(Trait::SPECIAL_INJURED)
          some_injuries = true
        end
  		end
  	end
    unless some_injuries || weapon_modifier > 0
      if ship.destroyed?
        add_list_item "Captain and crew were killed"
      else
        add_list_item "No injuries during the battle" 
      end
    end
    end_list unless weapon_modifier > 0
  end

  def end_of_battle?
  	defender.lost? || attacker.lost?
  end

  def report_subject
    @report_subject ||= "Space Battle: #{self.location.name}"
  end

  def report_top
    add_headline("Attacker: #{attacker}")
    add_line
  	add_headline("Defender: #{defender}")
    add_line
  end

  def report_start_round(round)
  	add_headline "Round #{round}"
    start_list
  end

  def report_explosion(ship)
  	add_line "[b]#{ship.name} exploded![/b]"
  end

  def report_breakdown(ship)
  	add_line "[b]#{ship.name} suffered an integrity breakdown.[/b]"
  end

  def report_weapon(ship, weapon, ammo_used, drones_launched, target, quantity, hits, damage, defense, saved)
  	weapon_desc = quantity == 1 ? weapon.name : weapon.name.pluralize
    if ammo_used && !ammo_used.empty?
      ammo_desc = ammo_used.select{|i| !i.nil?}.uniq.map{|i| i.name}.join(", ")
  	  weapon_desc = weapon_desc + " - #{ammo_desc} -" 
    end
    if weapon.drone_launcher?
      return if drones_launched.empty?
      m = drones_launched.keys.map do |d|
        "#{drones_launched[d]} x #{d.name}"
      end
      s = "#{ship.name} launched #{m.join(",")}"
    else
      s = "#{ship.name} fired #{quantity} x #{weapon_desc}"
    end
  	if hits == 1
      s = s + " hitting #{target.name} once"
    elsif hits > 0
      s = s + " hitting #{target.name} #{hits} times"
    else
      s = s + " but it failed to hit #{target.name}"
    end
    if saved == hits && hits > 0
      s = s + " and all hits were thwarted by #{defense}"
    elsif saved == 1
      s += ", one hit was neutralized by #{defense}" 
    elsif saved > 0
      s += ", #{saved} hits were neutralized by #{defense}" 
    end
    if damage > 0
  	 s += " - [b]#{damage} hull points of damage[/b]"
    end
  	add_list_item s
    self.report = self.report + @internal_damage unless @internal_damage.blank?
  end

  def report_internal_damage(ship, item, quantity)
  	@internal_damage = @internal_damage + " [*] #{ship.name} lost #{quantity} x #{item.name} due to hull damage.\n"
    #add_list_item "To Report Internal Damage - #{@internal_damage}"
  end

  def report_slowdown(ship,speed)
    @internal_damage = @internal_damage + " [*] #{ship.name} had its speed reduced to #{speed}"
  end

  def report_bottom
  	add_headline battle_status
    add_line
    add_line "Attacker: #{attacker} - Hull Points #{attacker.hull_points} / #{attacker.max_hull_points} (Integrity #{attacker.hull_integrity}%)"
    add_line "Defender: #{defender} - Hull Points #{defender.hull_points} / #{defender.max_hull_points} (Integrity #{defender.hull_integrity}%)"
    add_line
    add_line "[b]House #{attacker.noble_house.name} gained #{@attacker_glory} glory[/b]" if @attacker_glory > 0
    add_line "[b]House #{defender.noble_house.name} gained #{@defender_glory} glory[/b]" if @defender_glory > 0
    add_line
    add_headline "End of Battle"
  end

  def determine_status
    if defender.lost? && !attacker.lost?
	   self.battle_status = ATTACKER_WON 
    elsif attacker.lost? && !defender.lost?
  	 self.battle_status = DEFENDER_WON 
    elsif !attacker.lost? && attacker.hull_integrity > (defender.hull_integrity + 20)
      self.battle_status = ATTACKER_WON 
    elsif !defender.lost? && defender.hull_integrity > (attacker.hull_integrity + 20)
      self.battle_status = DEFENDER_WON 
    else
      self.battle_status = DRAW 
    end
  end

  def add_headline(s)
  	self.report = self.report + "[b]*** #{s} ***[/b]"
    add_line
  end

  def add_line(line='')
    self.report = self.report + line + "\n"
  end

  def start_list
    self.report = self.report + "[ul]"
  end

  def add_list_item(item)
    self.report = self.report + " [*] #{item}\n"
  end

  def end_list
    self.report = self.report + "[/ul]"
  end

end
