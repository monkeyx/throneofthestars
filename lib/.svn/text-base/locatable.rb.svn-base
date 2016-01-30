module Locatable
  def location
    return nil if self.location_type.blank? || location_id == 0
    k = Kernel.const_get(self.location_type)
    begin
      return k.find(location_id)
    rescue
      self.location_id = 0
      self.location_type = nil
      save
      return nil
    end
  end
  def location=(l)
    if l.nil?
      self.location_type = nil
      self.location_id = 0
    else
      self.location_type = l.class.to_s
      self.location_id = l.id
    end
  end

  def at_same_estate?(other)
    return false unless current_estate && other && (other.is_a?(Estate) || other.current_estate)
    if other.is_a?(Estate)
      other.id == current_estate.id
    else
      other.current_estate.id == current_estate.id
    end
  end

  def same_location?(other_position)
    return false if other_position.nil?
    return true if self.location_type == other_position.class.name && self.location_id == other_position.id
    return false if !other_position.respond_to?(:location) || other_position.location.nil? || self.location.nil?
    (other_position.location_type == self.location_type && other_position.location_id == self.location_id) || at_same_estate?(other_position)
  end

  def location_starship?
    self.location_type == 'Starship'
  end

  def location_estate?
    self.location_type == 'Estate'
  end

  def location_army?
    self.location_type == 'Army'
  end

  def location_world?
    self.location_type == 'World'
  end

  def location_region?
    self.location_type == 'Region'
  end

  def location_unit?
    self.location_type == 'Unit'
  end

  def location_foreign?
    self.location && foreign_to?(self.location)
  end

  def current_world
    return nil if location.nil?
    return self.location if location_type == 'World'
    return self.location.world if location_type == 'Region'
    return self.location.region.world if location_type == 'Estate'
    return self.location.army.current_world if location_type == 'Unit'
    return self.location.current_world if location.respond_to?(:current_world)
    nil
  end

  def current_region
    return nil if location.nil?
    return self.location if location_type == 'Region'
    return self.location.region if location_type == 'Estate'
    return self.location.army.current_region if location_type == 'Unit'
    return self.location.current_region if location.respond_to?(:current_region)
    nil
  end

  def current_estate
    return nil if location.nil?
    return self.location if location_type == 'Estate'
    return self.location.current_estate if (location_type == 'Army' || location_type == 'Starship')
    return self.location.army.current_estate if location_type == 'Unit'
    nil
  end

  def current_army
    return nil if location.nil?
    return self.location if location_type == 'Army'
    return self.location.army if location_type == 'Unit'
    nil
  end

  def current_starship
    return nil if location.nil?
    return self.location if location_type == 'Starship'
    return current_army.location if current_army && current_army.location_type == 'Starship'
    nil
  end
end
