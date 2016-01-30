module Starships
	NO_ARMOUR_COVERAGE = :no_armour
	LIGHT_ARMOUR_COVERAGE = :light_armour
	NORMAL_ARMOUR_COVERAGE = :normal_armour
	HEAVY_ARMOUR_COVERAGE = :heavy_armour

	ARMOUR = {NO_ARMOUR_COVERAGE => "None", LIGHT_ARMOUR_COVERAGE => "Light", NORMAL_ARMOUR_COVERAGE => "Normal", HEAVY_ARMOUR_COVERAGE => "Heavy"}

	ARMOUR_RANK = {NO_ARMOUR_COVERAGE => 0, LIGHT_ARMOUR_COVERAGE => 1, NORMAL_ARMOUR_COVERAGE => 2, HEAVY_ARMOUR_COVERAGE => 3}

	NO_SHIELDS = :no_shields
	LOW_SHIELDS = :low_shields 
	MEDIUM_SHIELDS = :medium_shields
	HIGH_SHIELDS = :high_shields

	SHIELDS = {NO_SHIELDS => "None", LOW_SHIELDS => "Low", MEDIUM_SHIELDS => "Medium", HIGH_SHIELDS => "High"}

	SHIELD_RANK = {NO_SHIELDS => 0, LOW_SHIELDS => 1, MEDIUM_SHIELDS => 1, HIGH_SHIELDS => 2}

	NO_STEALTH_PLATING = :no_stealth
	PARTIAL_STEALTH_PLATING = :partial_stealth
	FULL_STEALTH_PLATING = :full_stealth

	STEALTH_PLATING = {NO_STEALTH_PLATING => "None", PARTIAL_STEALTH_PLATING => "Partial", FULL_STEALTH_PLATING => "Full"}
	
	SPEED_SLOW = :slow_speed
	SPEED_NORMAL = :normal_speed
	SPEED_FAST = :fast_speed

	SPEED = {SPEED_SLOW => "Slow", SPEED_NORMAL => "Normal", SPEED_FAST => "Fast"}
	SPEED_RANK = {SPEED_SLOW => 1, SPEED_NORMAL => 2, SPEED_FAST => 3}
	SPEED_AT_RANK = {1 => SPEED_SLOW, 2 => SPEED_NORMAL, 3 => SPEED_FAST}

	def hull_size
		@hull_size ||= self.starship_type.hull_size
	end

	def hull_type
		@hull_type ||= self.starship_type.hull_type
	end

	def light_hull?
	    hull_type.light_hull?
	end

	def standard_hull?
	    hull_type.standard_hull?
	end

	def reinforced_hull?
	    hull_type.reinforced_hull?
	end

	def max_hull_points
	    @max_hull_points ||= hull_type.hull_points * hull_size
	end

	def sensor_profile_modifier
		return -1 if respond_to?(:debris?) && debris?
		return -1 if hull_size < 50
		return 0 if hull_size < 100
		return 2 if hull_size < 200
		4
	end

	def jammer_modifier
		return 0 if hull_size < 50
		return -1 if hull_size < 100
		return -2 if hull_size < 200
		-3
	end

	def calculate_armour_coverage(section_quantity)
		percentage = ((section_quantity.to_f / hull_size) * 100.0).round(0).to_i
		return NO_ARMOUR_COVERAGE if percentage < 20
		return LIGHT_ARMOUR_COVERAGE if percentage < 100
		return NORMAL_ARMOUR_COVERAGE if percentage < 200
		HEAVY_ARMOUR_COVERAGE
	end

	def better_armour_coverage?(a, b)
		ARMOUR_RANK[a] > ARMOUR_RANK[b]
	end

	def calculate_armour_save(item, section_quantity)
		return case calculate_armour_coverage(section_quantity)
		when LIGHT_ARMOUR_COVERAGE
			item.ship_armour_light
		when NORMAL_ARMOUR_COVERAGE
			item.ship_armour_normal
		when HEAVY_ARMOUR_COVERAGE
			item.ship_armour_heavy
		else
			0
		end
	end

	def calculate_ship_speed(section_quantity, section_dodge_speed)
		if standard_hull?
			if section_dodge_speed > 0
				ratio = hull_size / section_dodge_speed.to_f
				if section_quantity >= ratio
					return SPEED_FAST
				else
					return SPEED_NORMAL
				end
			else
				return SPEED_NORMAL
			end
		elsif reinforced_hull?
			if section_dodge_speed > 0
				ratio = hull_size / section_dodge_speed.to_f
				if section_quantity >= (ratio * 2)
					return SPEED_FAST
				elsif section_quantity >= ratio
					return SPEED_NORMAL
				else
					return SPEED_SLOW
				end
			else
				return SPEED_SLOW
			end
		else
			return SPEED_SLOW
		end
	end

	def faster_speed?(a,b)
		SPEED_RANK[a] > SPEED_RANK[b]
	end

	def calculate_shields(section_quantity)
		return NO_SHIELDS unless section_quantity > 0
		ratio = (hull_size / section_quantity)
		return HIGH_SHIELDS if ratio <= 20
		return MEDIUM_SHIELDS if ratio <= 50
		return LOW_SHIELDS if ratio <= 100
		NO_SHIELDS
	end

	def better_shields?(a, b)
		SHIELD_RANK[a] > SHIELD_RANK[b]
	end

	def calculate_energy_save(item, section_quantity)
		return case calculate_shields(section_quantity)
		when LOW_SHIELDS
			item.ship_shield_low
		when MEDIUM_SHIELDS
			item.ship_shield_medium
		when HIGH_SHIELDS
			item.ship_shield_high
		else
			0
		end
	end

	def calculate_stealth_plate_coverage(section_quantity)
		return NO_STEALTH_PLATING unless section_quantity > 0 && self.starship_type.armour_slots > 0
		percentage = ((section_quantity.to_f / self.starship_type.armour_slots) * 100.0).round(0).to_i
		return NO_STEALTH_PLATING if percentage < 50
		return PARTIAL_STEALTH_PLATING if percentage < 100
		FULL_STEALTH_PLATING
	end

	def calculate_thrust_speed(item, section_quantity)
		return 0 if section_quantity == 0 || item.thrust_speed == 0
		(hull_size / (item.thrust_speed * section_quantity).to_f).round(0).to_i
	end
	  
	def calculate_metrics(sections)
		starship_metrics = {}
		starship_metrics[:hull_size] = hull_size
		starship_metrics[:hull_type] = hull_type.name
		starship_metrics[:sensor_profile_modifier] = sensor_profile_modifier
		starship_metrics[:ship_speed] = calculate_ship_speed(0,0)
		starship_metrics[:max_hull_points] = max_hull_points
		starship_metrics[:hull_points] = hull_points if respond_to?(:hull_points)
		sections.each do |section|
			item = section.item
			qty = section.quantity
			if item.space_weapon?
				space_weapons = starship_metrics[:space_weapons]
				space_weapons = [] unless space_weapons
				space_weapons << section
				starship_metrics[:space_weapons] = space_weapons
			end
			if item.bombardment_weapon?
				bombardment_weapons = starship_metrics[:bombardment_weapons]
				bombardment_weapons = [] unless bombardment_weapons
				bombardment_weapons << section
				starship_metrics[:bombardment_weapons] = bombardment_weapons
			end
			if item.armour?
				armour_coverage = calculate_armour_coverage(qty)
				armour_save = calculate_armour_save(item,qty) 
				unless (starship_metrics[:armour_coverage] && better_armour_coverage?(starship_metrics[:armour_coverage], armour_coverage)) || (starship_metrics[:armour_save] && starship_metrics[:armour_save] > armour_save)
					starship_metrics[:armour_coverage] = armour_coverage
					starship_metrics[:armour_type] = item.name
					starship_metrics[:armour_save] = armour_save unless armour_save == 0
				end
			end
			if item.shield?
				shields = calculate_shields(qty)
				energy_save = calculate_energy_save(item, qty)
				starship_metrics[:shields] = shields unless starship_metrics[:shields] && better_shields?(starship_metrics[:shields], shields)
				starship_metrics[:energy_save] = energy_save unless energy_save == 0 || (starship_metrics[:energy_save] && starship_metrics[:energy_save] > energy_save)
			end
			if item.sensor?
				sensor_power = item.sensor_power
				sensor_power = sensor_power + (qty - 1) if qty > 1
				starship_metrics[:sensor_power] = sensor_power unless starship_metrics[:sensor_power] && starship_metrics[:sensor_power] > sensor_power
			end
			if item.stealth_plate?
				starship_metrics[:stealth_plating] = calculate_stealth_plate_coverage(qty)
				starship_metrics[:jammer_chance] = case starship_metrics[:stealth_plating]
				when FULL_STEALTH_PLATING
					item.jammer_power_full + jammer_modifier
				when PARTIAL_STEALTH_PLATING
					item.jammer_power_partial + jammer_modifier
				else
					0
				end
			elsif item.jammer?
				starship_metrics[:jammer_chance] = item.jammer_power_full + jammer_modifier
			end
			if item.accuracy_modifier
				starship_metrics[:accuracy_modifier] = item.accuracy_modifier unless starship_metrics[:accuracy_modifier] && starship_metrics[:accuracy_modifier] > item.accuracy_modifier
			end
			if item.bridge?
				starship_metrics[:bridge] = true
			end
			if item.cloak?
				starship_metrics[:cloak] = true
			end
			if item.escape_pod?
				starship_metrics[:escape_pod] = true
			end
			if item.nano_repair?
				starship_metrics[:nano_repair] = true
			end
			if item.impulse_speed && item.impulse_speed > 0
				starship_metrics[:impulse_speed] = item.impulse_speed unless starship_metrics[:impulse_speed] && starship_metrics[:impulse_speed] != 0 && starship_metrics[:impulse_speed] < item.impulse_speed
			end
			if item.impulse_modifier && item.impulse_modifier != 0
				modifier = starship_metrics[:impulse_modifier]
				modifier = 0 unless modifier
				modifier += item.impulse_modifier
				starship_metrics[:impulse_modifier] = modifier
			end
			if item.thrust_speed && item.thrust_speed != 0
				thrust_speed = calculate_thrust_speed(item, qty)
				starship_metrics[:thrust_speed] = thrust_speed unless starship_metrics[:thrust_speed] && starship_metrics[:thrust_speed] != 0 && starship_metrics[:thrust_speed] < thrust_speed
			end
			if item.dodge_speed && item.dodge_speed != 0
				speed = calculate_ship_speed(qty, item.dodge_speed)
				starship_metrics[:ship_speed] = speed unless faster_speed?(starship_metrics[:ship_speed], speed)
			end
			if item.orbital_trade
				starship_metrics[:orbital_trade] = true
			end
			if item.ammo_capacity && item.ammo_capacity > 0
				capacity = starship_metrics[:ammo_capacity]
				capacity = 0 unless capacity
				capacity += (item.ammo_capacity * qty)
				starship_metrics[:ammo_capacity] = capacity
			end
  			if item.worker_capacity && item.worker_capacity > 0
				capacity = starship_metrics[:worker_capacity]
				capacity = 0 unless capacity
				capacity += (item.worker_capacity * qty)
				starship_metrics[:worker_capacity] = capacity
  			end
  			if item.troop_capacity && item.troop_capacity > 0
				capacity = starship_metrics[:troop_capacity]
				capacity = 0 unless capacity
				capacity += (item.troop_capacity * qty)
				starship_metrics[:troop_capacity] = capacity
  			end
  			if item.ore_capacity && item.ore_capacity > 0
				capacity = starship_metrics[:ore_capacity]
				capacity = 0 unless capacity
				capacity += (item.ore_capacity * qty)
				starship_metrics[:ore_capacity] = capacity
  			end
  			if item.cargo_capacity && item.cargo_capacity > 0
				capacity = starship_metrics[:cargo_capacity]
				capacity = 0 unless capacity
				capacity += (item.cargo_capacity * qty)
				starship_metrics[:cargo_capacity] = capacity
  			end
		end
		starship_metrics
	end
end