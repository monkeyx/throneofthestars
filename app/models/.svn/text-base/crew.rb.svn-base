class Crew < ActiveRecord::Base
	attr_accessible :starship, :character, :lieutenant
	
	belongs_to :starship
	belongs_to :character
	# lieutenant

	scope :onboard, lambda {|starship|
	{:conditions => {:starship_id => starship.id}}
	}

	scope :lieutenants, {:conditions => {:lieutenant => true}}
	scope :ensigns, {:conditions => {:lieutenant => false}}
  
	def self.assign_crew!(starship, character)
		crew = find_by_starship_id_and_character_id(starship.id, character.id)
		if crew
			if starship.onboard?(character)
				if !crew.lieutenant && character.adult?
					crew.lieutenant = true
					crew.save
					Title.appoint_lieutenant!(character, starship)
				end
				return crew
			end
		else
			crew = create!(:starship => starship, :character => character, :lieutenant => character.adult?)
		end
		if crew.lieutenant
			Title.appoint_lieutenant!(character, starship)
		else
			Title.appoint_ensign!(character, starship)
		end
		crew
	end

	def self.unassign_crew!(starship, character)
		crew = find_by_starship_id_and_character_id(starship.id, character.id)
		return false unless crew
		Title.belonging_to(character).starship(starship).categories(Title::CREW_TITLES).each {|t| t.revoke!}
		crew.destroy
	end

end

