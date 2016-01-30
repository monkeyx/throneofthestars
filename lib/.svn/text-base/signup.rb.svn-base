module Signup
  def do_signup!(params)
    transaction do
      NobleHouse.update_all('player_id = NULL', ['player_id = ? AND id <> ?',self.player_id,self.id])
      if self.player.gm
        update_attributes!(:wealth => 1000000000)
      end

      p = Character.seed!(params['PATRIARCH'],self,Character::MAJOR,Character::MALE,(Game.current_date - 400 - "1d20".roll))
      p.mature!({params['PATRIARCH_SKILL1'] => Skill::EXPERT,
                            params['PATRIARCH_SKILL2'] => Skill::EXPERT,
                            params['PATRIARCH_SKILL3'] => Skill::APPRENTICE})
      p.add_title!(Title::BARON,self)
      m = Character.seed!(params['MATRIARCH'],self,Character::MAJOR,Character::FEMALE,(Game.current_date - 350 + "2d10".roll))
      m.mature!({params['MATRIARCH_SKILL1'] => Skill::EXPERT,
                 params['MATRIARCH_SKILL2'] => Skill::APPRENTICE,
                 params['MATRIARCH_SKILL3'] => Skill::APPRENTICE})
      p.betrothed!(m)
      p.marry!

      region = Region.find(params['REGION'])

      estate = Estate.build!(self,region,params['ESTATE_NAME'])
      if self.player.gm
        estate.claim_lands!(120,0)
      else
        estate.claim_lands!(20,0)
      end
      
      estate.construct!(BuildingType.building_type(BuildingType::PALACE),true)
      estate.construct!(BuildingType.building_type(BuildingType::TRADE_HALL),true)
      estate.construct!(BuildingType.building_type(BuildingType::BARRACKS),true)
      estate.construct!(BuildingType.building_type(BuildingType::SHUTTLE_PORT),true)
      estate.construct!(BuildingType.building_type(BuildingType::ORBITAL_DOCK),true)

      if self.player.gm
        building_level = 20
      else
        building_level = 2
      end

      building_level.times {estate.construct!(BuildingType.building_type(BuildingType::WORKSHOP),true)}
      Resource.at(region).yield_category(Resource::RICH).each do |resource|
        building_level.times {estate.construct!(resource.building_type,true)} if resource.item.rich_yield > 0
      end
      Resource.at(region).yield_category(Resource::NORMAL).each do |resource|
        building_level = building_level / 2
        building_level.times {estate.construct!(resource.building_type,true)} if resource.item.normal_yield > 0
      end
      estate.noble_house = self
      estate.save!
      estate.reload

      p.update_attributes!(:birth_place => estate)

      ages = []
      3.times do
        n = ("1d6+19".roll * 10) + "1d10-1".roll
        ages << Game.current_date - n
      end

      child1 = Character.give_birth!(p,m,estate,ages[0],Character::MALE,params['FIRST_CHILD_NAME'])
      child1.mature!({params['FIRST_CHILD_SKILL'] => Skill::APPRENTICE})
      child2 = Character.give_birth!(p,m,estate,ages[1],Character::MALE,params['SECOND_CHILD_NAME'])
      child2.mature!({params['SECOND_CHILD_SKILL'] => Skill::APPRENTICE})
      child3 = Character.give_birth!(p,m,estate,ages[2],Character::FEMALE,params['THIRD_CHILD_NAME'])
      child3.mature!({params['THIRD_CHILD_SKILL'] => Skill::APPRENTICE})

      3.times do
        n = ("1d6+7".roll * 10) + "1d10-1".roll
        child = Character.give_birth!(p,m,estate,(Game.current_date - n))
        child.mature!
      end

      self.characters.each{|c| c.move_to_home_estate! }

      population_needed = {}
      estate.buildings.each do |building|
        building.workers_needed_by_type.each do |worker_type, quantity|
          qty = population_needed[worker_type]
          qty = 0 unless qty
          qty += quantity
          population_needed[worker_type] = qty
        end
      end
      population_needed.each do |worker_type,quantity|
        estate.add_population!(worker_type,quantity)
      end
      soldiers = self.player.gm ? 10000 : 100
      marines = self.player.gm ? 10000 : 100
      tanks = self.player.gm ? 10000 : 100
      estate.add_item!(Item.named("Soldier").first, soldiers)
      estate.add_item!(Item.named("Light Tank").first, marines)
      estate.add_item!(Item.named("Defense Bunker").first, tanks)
      p.add_title!(Title::LORD,estate)
      update_attributes!(:active => true)

      reload
      if self.player.gm
        (1..4).each{Spawner.ship_with_captain(self, 'Imperial Cruiser','Nanite Missile', 'Phased Torpedo')}
        (1..4).each{Spawner.ship_with_captain(self, 'Imperial Transport')}
        (1..2).each{Spawner.ship_with_captain(self, 'Ship of the Line','Nanite Missile', 'Phased Torpedo', 'Guardian')}
      else
        corvette = Starship.build_starship!("#{self.name} Corvette", StarshipConfiguration.corvette.first, estate, true)
        courier = Starship.build_starship!("#{self.name} Courier", StarshipConfiguration.courier.first, estate, true)
      end

      add_empire_news!("HOUSE_FORMED")
      automated_appointments!(true,{:steward => true, :tribune => true, :captain => true, :chancellor => true})
      automated_appointments!(false,{:steward => true})

      estate.reload
      estate.automated_resource_gathering!

      player.deliver_signup_complete!
      unless self.player.gm
        Message.send_from_gm!(self.baron, "Welcome to Throne of the Stars", 
          "Greetings #{self.baron.display_name},

          Welcome to Throne of the Stars! Please find attached a little bit of extra cash to help you on your way.

          I would recommend that you take a look at the tutorial [url=#{$WIKI_BASE}Tutorial]here[/url] before you start.

          You can find all the rules for the game on the wiki [url=#{$WIKI_HOME}]here[/url].

          There is also a [url=#{$FORUM_HOME}]forum[/url] for community support, where you can ask questions and report any issues you may experience.

          I wish you fun and success!

          Yours,

          #{Player.gm.noble_house.baron.display_name}
          ", 10000)
      end
      true
    end
  end

end
