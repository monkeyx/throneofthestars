module AncientHouse
  include Log

  def self.create_ancient_house!(region,name=region.name.pluralize,orbital_docks=false)
    # create house
    Log.info "ANCIENT HOUSE", "Adding House #{name}"
    formed_date = GameDate.new(1,1,1)
    house = NobleHouse.create!(:name => name, :wealth => 100000, :honour => 100, :glory => 100, :piety => 0, :formed_date => formed_date, :ancient => true, :active => true)
    # create characters
    patriarch = Character.seed!(Names.random_name(Character::MALE),house,Character::MAJOR,Character::MALE,(Game.current_date - 400 - "1d10-9".roll))
    civil_skill = Skill::CIVIL_SKILLS.sample
    patriarch.mature!({Skill::MILITARY_SKILLS.sample => Skill::EXPERT,
                          Skill::MILITARY_SKILLS.sample => Skill::APPRENTICE,
                          civil_skill => Skill::EXPERT})
    patriarch.add_title!(Title::BARON,house)
    patriarch.move_to_home_estate!
    patriarch.train!(civil_skill)
    matriarch = Character.seed!(Names.random_name(Character::FEMALE),house,Character::MAJOR,Character::FEMALE,(Game.current_date - 400 - "1d10-9".roll))
    church_skill = Skill::CHURCH_SKILLS.sample
    matriarch.mature!({Skill::CIVIL_SKILLS.sample => Skill::EXPERT,
                          church_skill => Skill::APPRENTICE})

    matriarch.move_to_home_estate!
    matriarch.train!(church_skill)
    patriarch.betrothed!(matriarch)
    patriarch.marry!

    # create estate
    estate = Estate.build!(house,region,name,formed_date)
    estate.claim_lands!(100,0)
    estate.construct!(BuildingType.building_type(BuildingType::PALACE),true,formed_date)
    estate.construct!(BuildingType.building_type(BuildingType::TRADE_HALL),true,formed_date)
    estate.construct!(BuildingType.building_type(BuildingType::BARRACKS),true,formed_date)
    estate.construct!(BuildingType.building_type(BuildingType::ORBITAL_DOCK),true,Game.current_date) if orbital_docks

    Resource.at(region).yield_category(Resource::RICH).each do |resource|
      3.times {estate.construct!(resource.building_type,true,formed_date)} if resource.item.rich_yield > 0
    end
    Resource.at(region).yield_category(Resource::NORMAL).each do |resource|
      2.times {estate.construct!(resource.building_type,true,formed_date)} if resource.item.normal_yield > 0
    end

    estate.save!
    estate.reload

    # children
    "1d6+2".roll.times do
      age = "2d6+16".roll
      skill = (Skill::CIVIL_SKILLS + Skill::MILITARY_SKILLS).sample
      child = Character.give_birth!(patriarch,matriarch,estate,(Game.current_date - (age * 10 - "1d10-9".roll)))
      child.mature!({skill => Skill::APPRENTICE})
      child.train!(skill)
    end
    "1d4-1".roll.times do
      age = "2d6".roll
      child = Character.give_birth!(patriarch,matriarch,estate,(Game.current_date - (age * 10 - "1d10-9".roll)))
      child.mature!
    end

    # add population
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
    soldier = Item.named("Soldier").first
    fighter = Item.named("Fighter").first
    estate.add_item!(soldier, 1000)
    estate.add_item!(Item.named("Marine").first, 250)
    estate.add_item!(Item.named("Defense Bunker").first, 250)
    estate.add_item!(fighter, 100)

    patriarch.add_title!(Title::LORD,estate)
    patriarch.add_title!(Title::EARL,region)

    # create army
    army = Army.create_army!("House #{house.name} Guards", estate)
    army.create_unit!("1st Infantry",soldier,1000)
    army.create_unit!("1st Armoured",Item.named("Light Tank").first, 1000)
    army.create_unit!("Air Defense",fighter, 50)

    house.reload
    
    house.automated_appointments!
    house.automated_appointments!(false)

    house
  end

end
