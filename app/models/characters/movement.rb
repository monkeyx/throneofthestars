module Characters
  module Movement
    def move_apprentices!
      self.apprentices.each do |apprentice|
        apprentice.novice.location = self.location
        apprentice.novice.save!
      end
    end

    def move_to_estate!(estate,ignore_distance=false)
      return false if estate.nil? || (self.location_type == 'Estate' && self.location_id == estate.id)
      return false if !ignore_distance && estate.region.world.id != current_world.id
      if location_starship?
        location.update_attributes!(:captain_id => nil) if location.captain_id == self.id
        Title.remove_titles!(self,[Title::CAPTAIN])
        Crew.unassign_crew!(self.location,self)
      end
      if location_army?
        location.update_attributes!(:legate_id => nil) if location.legate_id == self.id
        Title.remove_titles!(self,[Title::LEGATE])
      end
      Title.remove_titles!(self,Title::LOCATION_FIXED_TITLES)
      self.location = estate
      save!
      add_news!("CHARACTER_MOVE_ESTATE",self.location)
      move_apprentices!
      Title.appoint_emissary!(self, self.location) if adult? && location_foreign?
      true
    end

    def move_to_home_estate!
      if self.noble_house && self.noble_house.home_estate
        location.update_attributes!(:captain_id => nil) if location_starship? && location.captain_id == self.id
        location.update_attributes!(:legate_id => nil) if location_army? && location.legate_id == self.id
        Title.remove_titles!(self,Title::LOCATION_FIXED_TITLES)
        Crew.unassign_crew!(self.location,self) if self.location_starship?
        self.location = self.noble_house.home_estate
        save!
        add_news!("CHARACTER_HOME", self.noble_house.home_estate)
        move_apprentices!
        return true
      end
      false
    end

    def move_to_nearest_estate!
      return false if self.location_type == 'Estate' && self.location.noble_house_id == self.noble_house_id # already at own estate
      move_to_home_estate! if self.location_type.nil? || self.location_id.nil? # in the void
      if location.respond_to?(:region) && location.region
        # in a region so move to an estate in the region if possible
        list = Estate.of(self.noble_house).at(location.region)
        if list.size > 0
          return move_to_estate!(list.first)
        end
      end
      # Not at a region or no estate of house in this region, try the world we're on
      if location.respond_to?(:world) && location.world
        list = Estate.of(self.noble_house).on(location.world)
        if list.size > 0
          return move_to_estate!(list.first)
        end
      end
      move_to_home_estate! # OK nothing on the world so move home
    end

    def board_starship!(starship)
      Title.remove_titles!(self,[Title::EMISSARY])
      self.location = starship
      save!
      add_news!("CHARACTER_BOARD_STARSHIP",self.location)
      move_apprentices!
      true
    end

    def disembark_starship!
      raise "Not on a starship #{starship.name}" unless self.location_type == 'Starship'
      raise "Not docked at an estate" unless self.location.location_estate?
      location.update_attributes!(:captain_id => nil) if location_starship? && location.captain_id == self.id
      self.location = self.location.location
      save!
      add_news!("CHARACTER_UNBOARD_STARSHIP",self.location)
      move_apprentices!
      true
    end

    def join_army!(army)
      return false unless army
      return false if self.location_type == 'Army' && self.location_id == army.id
      raise "Female characters cannot join armies" if female?
      raise "Mot in same location as army #{army.name}" unless self.current_estate == army.current_estate
      self.location = army
      save!
      add_news!("JOIN_ARMY",army)
      move_apprentices!
      true
    end

    def join_unit!(unit)
      return false unless unit
      return false if self.location_type == 'Unit' && self.location_id == unit.id
      raise "Not in same location as unit #{unit.name}" unless at_same_estate?(unit.army)
      self.location = unit
      save!
      add_news!("JOIN_UNIT",unit)
      move_apprentices!
      true
    end
  end
end
