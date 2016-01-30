class Apprentice < ActiveRecord::Base
  attr_accessible :novice, :character, :accepted
  
  belongs_to :novice, :class_name => 'Character'
  belongs_to :character
  # accepted

  scope :apprenticeship, lambda {|novice|
    {:conditions => {:novice_id => novice.id}}
  } 

  scope :apprentices, lambda {|character|
    {:conditions => {:character_id => character.id}}
  } 

  scope :accepted, :conditions => {:accepted => true}
  scope :pending, :conditions => {:accepted => false}

  def self.offer_apprentice!(emissary, novice, character)
  	return false if !novice.can_become_apprentice? || !character.can_have_apprentices?
  	return false if novice.male? && character.female? && !(character.knight? || character.captain?)
  	return false if novice.female? && character.male? && !(character.knight? || character.captain?)
  	apprenticeship = create!(:novice => novice, :character => character, :accepted => false)
  	emissary.add_news!('OFFER_APPRENTICE',"#{character.display_name} of #{novice.display_name}")
  	character.add_news!('APPRENTICE_OFFERED',novice)
  	return apprenticeship.accept! if character.noble_house.ancient?
  	true
  end

  def self.expire_apprenticeship_offers!(novice)
  	Apprentice.apprenticeship(novice).pending.each{|app| app.destroy }
  end

  def accept!
  	return false if !novice.can_become_apprentice? || !character.can_have_apprentices?
  	return false if novice.male? && character.female? && !(character.knight? || character.captain?)
  	return false if novice.female? && character.male? && !(character.knight? || character.captain?)
  	return false unless character.current_estate || character.location_starship?
  	novice.move_to_estate!(character.current_estate,true)  unless character.location_starship?
  	if character.knight?
  		unit = character.location_unit? ? character.location : nil
  		Title.appoint_squire!(novice,unit)
  	elsif character.captain?
  		Crew.assign_crew!(character.location,novice)
  	elsif character.lord? || character.lady? || character.baron? || character.baroness?
  		estate = character.current_estate ? character.current_estate : character.noble_house.home_estate
  		if novice.male?
  			Title.become_ward!(novice,estate)
  		else
  			Title.become_lady_in_waiting!(novice,estate)
  		end
  	else
  		return false # not sure how we would get here if can_have_apprentice? is properly implemented
  	end
  	update_attributes!(:accepted => true)
  	novice.location = character.location
  	novice.save!
  	Apprentice.expire_apprenticeship_offers!(novice)
    if novice.male?
      novice.add_news!('APPRENTICESHIP_START_BOY')
    else
      novice.add_news!('APPRENTICESHIP_START_GIRL')
    end
  	character.add_news!('APPRENTICE_ACCEPTED',novice)
  	true
  end

  def end!(move_home=true)
  	Title.remove_apprenticeship_titles!(novice)
    if novice.male?
      novice.add_news!('APPRENTICESHIP_ENDED_BOY')
    else
      novice.add_news!('APPRENTICESHIP_ENDED_GIRL')
    end
  	character.add_news!('APPRENTICE_LEFT',novice)
  	novice.move_to_home_estate! if move_home
  	destroy
  end

  def complete!(move_home=true)
  	Title.remove_apprenticeship_titles!(novice)
    if novice.male?
  	  novice.add_news!('APPRENTICESHIP_COMPLETED_BOY')
      character.add_news!('APPRENTICE_GRADUATED_BOY',novice)
    else
      novice.add_news!('APPRENTICESHIP_COMPLETED_GIRL')
      character.add_news!('APPRENTICE_GRADUATED_GIRL',novice)
    end
  	novice.move_to_home_estate! if move_home
  	destroy
  end
end
