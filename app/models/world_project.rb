class WorldProject < ActiveRecord::Base
	attr_accessible :world, :category, :build_date
	
	SCIENCE_ACADEMY = "Science Academy"
	ENGINEERING_ACADEMY = "Engineering Academy"
	GRAND_ACADEMY = "Grand Academy"
	AIR_WARFARE = "Air Warfare Doctrine"
	STRATEGIC_WARFARE = "Strategic Warfare Doctrine"
	ORBITAL_WARFARE = "Orbital Warfare Doctrine"
	MECHANIZED_INFANTRY = "Mechanized Infantry Training"
	COMBINED_ARMS = "Combined Arms Training"
	SPECIAL_FORCES = "Special Forces Training"
	SPIRIT_ATOM = "Spirit of the Atom"
	SPIRIT_MACHINE = "Spirit of the Machine"
	SPIRIT_LIVING = "Spirit of the Living"
	FAITH_SHADOW = "Faith in Shadow"
	FAITH_LIGHT = "Faith in Light"
	FAITH_QUANTUM = "Faith in Quantum"
	DEVOTION_ENERGY = "Devotion of Energy"
	DEVOTION_MATTER = "Devotion of Matter"
	DEVOTION_ENTROPY = "Devotion of Entropy"

	PROJECT_TYPES = [SCIENCE_ACADEMY, ENGINEERING_ACADEMY, GRAND_ACADEMY,
									AIR_WARFARE, STRATEGIC_WARFARE, ORBITAL_WARFARE,
									MECHANIZED_INFANTRY, COMBINED_ARMS, SPECIAL_FORCES,
									SPIRIT_ATOM, SPIRIT_MACHINE, SPIRIT_LIVING,
									FAITH_SHADOW, FAITH_LIGHT, FAITH_QUANTUM,
									DEVOTION_ENERGY, DEVOTION_MATTER, DEVOTION_ENTROPY
	]
	
	belongs_to :world
	validates_inclusion_of :category, :in => PROJECT_TYPES
	game_date :build_date

  def self.build_project!(world, category)
    return if world.has_project? category
    create!(:world => world, :category => category, :build_date => Game.current_date)
  end
end
