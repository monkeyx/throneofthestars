module HousePosition
  def of_same_house?(other)
    return false if other.nil? || !other.respond_to?(:noble_house)
    self.noble_house == other.noble_house
  end

  def foreign_to?(other)
  	!of_same_house?(other)
  end

  alias_method :same_house?, :of_same_house?

end
