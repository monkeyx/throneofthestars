class DiplomaticToken < ActiveRecord::Base
  attr_accessible :diplomatic_relation, :estate, :sovereigns, :lands, :oath

  belongs_to :diplomatic_relation
  belongs_to :estate
  validates_numericality_of :sovereigns
  # oath
  validates_numericality_of :lands, :only_integer => true

  def self.give_land(estate,lands)
    new(:estate => estate, :lands => lands)
  end

  def self.give_estate(estate)
    new(:estate => estate)
  end

  def self.give_sovereigns(sovereigns)
    new(:sovereigns => sovereigns)
  end

  def self.give_oath
    new(:oath => true)
  end

  def valid_for?(relationship)
    return false if self.lands && self.lands > 0 && (!self.estate || self.estate.free_lands < self.lands)
    return false if self.estate && self.estate.noble_house_id != relationship.noble_house_id
    return false if self.sovereigns && !relationship.noble_house.has_funds?(self.sovereigns)
    true
  end

  def to_s
    if self.lands && self.estate && self.lands > 0
      "#{self.lands} #{(self.lands == 1 ? 'land' : 'lands')} from Estate #{self.estate.name} in #{self.estate.region.name} on #{self.estate.region.world.name}"
    elsif self.estate
      "Estate #{self.estate.name} in #{self.estate.region.name} on #{self.estate.region.world.name}"
    elsif self.sovereigns && self.sovereigns > 0
      "&pound; #{self.sovereigns}"
    elsif self.oath
      "an oath of allegiance"
    end
  end
end
