class Spawner
	include Names
	include AncientHouse

	PRIZE_NEWS_CODES = ['CHURCH_GIFT','MERCHANT_GIFT','TEMPLAR_GIFT']

	def self.space_battle(config_a, config_b=config_a, missiles_type='Nuclear Missile', torpedo_type='Proton Torpedo', drone_type='Interceptor')
		Game.transaction do
			house = Spawner.house
			house2 = Spawner.rival_house(house)
			ship1 = Spawner.ship_with_captain(house,config_a,missiles_type,torpedo_type,drone_type)
			ship2 = Spawner.ship_with_captain(house2,config_b,missiles_type,torpedo_type,drone_type)
			battle = SpaceBattle.fight!(ship1,ship2)
			Player.gm.noble_house.baron.send_internal_message!(battle.report_subject, battle.report)
		end
	end

	def self.ground_battle
		Game.transaction do
			house = Spawner.house
			house2 = Spawner.rival_house(house)
			army1 = Spawner.army_with_legate(house)
			army2 = Spawner.army_with_legate(house2)
			army2.location = army1.location
			battle = GroundBattle.fight!(army1,army2)
			Player.gm.noble_house.baron.send_internal_message!(battle.report_subject, battle.report)
		end
	end

	def self.capture_estate
		Game.transaction do
			house = Spawner.house
			house2 = Spawner.rival_house(house)
			army = Spawner.army_with_legate(house)
			estate = house2.home_estate
			army.location = estate.region
			battle = GroundBattle.fight!(army,estate)
			Player.gm.noble_house.baron.send_internal_message!(battle.report_subject, battle.report)
		end
	end

	def self.house(region=Region.all.sample)
		Game.transaction do
			name = Names::HOUSE_NAMES[rand(Names::HOUSE_NAMES.length)] + " #{rand(36**8).to_s(36)}"
			AncientHouse.create_ancient_house!(region, name, true)
		end
	end

	def self.rival_house(house)
		Game.transaction do
			house2 = Spawner.house(house.home_estate.region)
			DiplomaticRelation.create_relation!(house,house2,house.baron,DiplomaticRelation::WAR,DiplomaticRelation::ATTACK_HOUSE)
			house2
		end
	end

	def self.major_adult(house, male=true)
		Game.transaction do
			gender = male ? Character::MALE : Character::FEMALE
			Character.seed!(Names.random_name(gender),house,Character::MAJOR,gender,(Game.current_date - 210))
		end
	end

	def self.civil_servant(house)
		Game.transaction do
			c = major_adult(house)
			skills = {}
			Skill::CIVIL_SKILLS.each{|s| r = rand(3); skills[s] = r if r > 0}
			c.mature!(skills)
			c.reload
			skill = c.skills.sample
			skill.train! if skill
			c.move_to_home_estate!
			c
		end
	end

	def self.acolyte(house)
		Game.transaction do
			c = major_adult(house)
			skills = {}
			Skill::CHURCH_SKILLS.each{|s| r = rand(3); skills[s] = r if r > 0}
			c.mature!(skills)
			c.reload
			skill = c.skills.sample
			skill.train! if skill
			c.move_to_home_estate!
			c
		end
	end

	def self.captain(house)
		Game.transaction do
			c = major_adult(house)
			skills = {}
			Skill::NAVAL_SKILLS.each{|s| r = rand(3); skills[s] = r if r > 0}
			c.mature!(skills)
			c.reload
			skill = c.skills.sample
			skill.train! if skill
			c.move_to_home_estate!
			c
		end
	end

	def self.legate(house)
		Game.transaction do
			c = major_adult(house)
			skills = {}
			Skill::MILITARY_SKILLS.each{|s| r = rand(3); skills[s] = r if r > 0}
			c.mature!(skills)
			c.reload
			skill = c.skills.sample
			skill.train! if skill
			c.move_to_home_estate!
			c
		end
	end

	def self.ship_with_captain(house, configuration_name, missiles_type='Nuclear Missile', torpedo_type='Proton Torpedo', drone_type='Interceptor')
		Game.transaction do
			c = captain(house)
			ship = Starship.build_starship!("#{house.name} #{configuration_name}", StarshipConfiguration.find_by_name(configuration_name), house.home_estate, true)
			ship.embark_character!(c)
			
			torpedo_launcher = Item.find_by_name('Torpedo Launcher')
			torpedo = Item.find_by_name(torpedo_type)
			missile_launcher = Item.find_by_name('Missile Launcher')
			missile =Item.find_by_name(missiles_type)
			drone_bay = Item.find_by_name('Drone Bay')
			drone = Item.find_by_name(drone_type)
			magazine = Item.find_by_name('Magazine')
			mg = ship.count_section(magazine)
			ammo_capacity = mg * magazine.ammo_capacity

			tpl = ship.count_section(torpedo_launcher)
			ml = ship.count_section(missile_launcher)
			d = ship.count_section(drone_bay)

			total_ammo_using = tpl + ml + d
			ammo_space_per_weapon = 0
			ammo_space_per_weapon = (ammo_capacity / total_ammo_using) if total_ammo_using > 0

			torps = 0
			missiles = 0
			drones = 0
			torps = (tpl * ammo_space_per_weapon) / 5 if tpl > 0
			missiles = (ml * ammo_space_per_weapon) / 2 if ml > 0
			drones = (d * ammo_space_per_weapon) / 20 if d > 0

			ship.add_item!(torpedo, torps) if torps > 0
			ship.add_item!(missile, missiles) if missiles > 0
			ship.add_item!(drone, drones) if drones > 0
			
			bunks = Item.find_by_name('Bunks')
			marines = Item.find_by_name('Marine')
			b = ship.count_section(bunks)
			ship.add_item!(marines,b * bunks.troop_capacity)

			ship.take_off!
			ship
		end
	end

	def self.army_with_legate(house)
		Game.transaction do
			c = legate(house)
			army = Army.create_army!("#{house.name} #{(house.armies.size + 1).ordinalize}", house.home_estate, c)
			army.create_unit!("Soldiers",Item.find_by_name('Soldier'),rand(1000))
			army.create_unit!("Marines",Item.find_by_name('Marine'),rand(1000))
			army.create_unit!("Light Tanks",Item.find_by_name('Light Tank'),rand(1000))
			army.create_unit!("Battle Tanks",Item.find_by_name('Battle Tank'),rand(1000))
			army.create_unit!("Fighters",Item.find_by_name('Fighter'),rand(1000))
			army.create_unit!("Gunships",Item.find_by_name('Gunship'),rand(1000))
			army.create_unit!("Bombers",Item.find_by_name('Bomber'),rand(1000))
			army.create_unit!("Rocket Artillery",Item.find_by_name('Rocket Artillery'),rand(1000))
			army
		end
	end

	def self.prize_ship(house,configuration_name, news_code,estate_name=nil,artefact_name=nil)
		Game.transaction do
			if estate_name && artefact_name
				e = Estate.find_by_name_and_noble_house_id(estate_name,house.id)
				return false unless e
				artefact = Item.find_by_name(artefact_name)
				raise "Invalid artefact" unless artefact
				c = e.count_item(artefact)
				return false unless c > 0
				e.remove_item!(artefact,1)
			end
			ship = ship_with_captain(house, configuration_name)
			house.add_empire_news!(news_code, configuration_name)
			Rails.cache.clear
			ship
		end
	end

	def self.debris(house,configuration_name,world,cargo={})
		Game.transaction do
			ship = Starship.build_starship!("#{configuration_name} Debris", StarshipConfiguration.find_by_name(configuration_name), house.home_estate, true)
			cargo.keys.each do |item|
				ship.add_item!(item,cargo[item])
			end
			ship.location = world
			ship.save!
			ship.breakdown!
			ship
		end
	end

	def self.artefact_debris(configuration_name,world,artefact_item)
		d = debris(NobleHouse.gm,configuration_name,world,{artefact_item => 1})
		Kernel.p "Seeded debris of #{configuration_name} with #{artefact_item.name} in orbit of #{world.name}"
		d
	end

	def self.seed_artefacts
		Game.transaction do
			relic = Item.find_by_name('Relic')
			artefact = Item.find_by_name('Artefact')
			nanite = Item.find_by_name('Nanites')
			goo = Item.find_by_name('Goo')
			anomaly = Item.find_by_name('Anomaly')
			World.all.each do |world|
				roll = "1d8".roll
				case roll
				when 8
					artefact_debris('Ranger',world,goo)
				when 7
					artefact_debris('Ranger',world,nanite)
				when 6
					artefact_debris('Ranger',world,artefact)
				when 5
					artefact_debris('Ranger',world,anomaly)
				when 4
					artefact_debris('Courier',world,relic)
				when 3
					artefact_debris('Courier',world,relic)
				when 2
					artefact_debris('Courier',world,relic)
				when 1
					artefact_debris('Courier',world,relic)
		  		end
		  	end
		end
	end
end