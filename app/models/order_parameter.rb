class OrderParameter < ActiveRecord::Base
  attr_accessible :order, :order_id, :label, :parameter_type, :parameter_value, :required

  KNOWNN_INTEGER_FIELDS = ['Quantity','Levels','Chronums Until Start','Offer Lands']
  
  TEXT = "Text"
  TEXT_AREA = "Text Area"
  NUMBER = "Number"
  BOOLEAN = "Boolean"
  ITEM = "Item"
  WORKER_TYPE = "Worker Type"
  BUILDING_TYPE = "Building Type"
  STARSHIP_TYPE = "Starship Type"
  STARSHIP_CONFIGURATION = "Starship Configuration"
  SKILL = "Skill"
  NOBLE_HOUSE = "Noble House"
  NOBLE_HOUSE_INCLUDE_ANCIENT = "Noble House Include Ancient"
  SINGLE_FEMALE = "Potential Spouse"
  SINGLE_MALE = "Potential Husband"
  CHARACTER = "Character"
  OWN_CHARACTER = "Own Character"
  CHARACTER_ESTATE = "Character at Estate"
  PRISONER_ESTATE = "Prisoner at Estate"
  PRISONER_HOUSE = "Prisoner of House"
  BRIDE = "Bride"
  WORLD = "World"
  REGION = "Region"
  OWN_ESTATE = "Own Estate"
  WORLD_ESTATE = "World Estate"
  OWN_ARMY = "Own Army"
  UNIT = "Unit"
  OWN_STARSHIP = "Own Starship"
  ESTATE = "Estate"
  SCANNED_SHIP = "Scanned Ship"
  PROJECT = "Project"
  LAW = "Law"
  PERSONAL_COMBAT = "Personal Combat"
  INFORMATION_TYPE = "Information Type"

  PARAMETER_TYPES = [TEXT, TEXT_AREA, NUMBER, BOOLEAN,
  ITEM, WORKER_TYPE, BUILDING_TYPE,
  STARSHIP_TYPE, STARSHIP_CONFIGURATION,
  SKILL,NOBLE_HOUSE,NOBLE_HOUSE_INCLUDE_ANCIENT,
  OWN_CHARACTER, SINGLE_FEMALE, SINGLE_MALE, CHARACTER, BRIDE, CHARACTER_ESTATE,
  PRISONER_ESTATE, PRISONER_HOUSE,
  WORLD, REGION, 
  OWN_ESTATE, OWN_ARMY, WORLD_ESTATE,
  UNIT,OWN_STARSHIP, ESTATE,
  SCANNED_SHIP, PROJECT, LAW,
  PERSONAL_COMBAT, INFORMATION_TYPE]

  belongs_to :order
  validates_presence_of :label
  validates_inclusion_of :parameter_type, :in => PARAMETER_TYPES
  # parameter_value
  validate :validate_parameter
  # required

  def parameter_value_obj
    return nil if self.parameter_value.blank?
    @value_object ||= case self.parameter_type
    when TEXT
      self.parameter_value
    when TEXT_AREA
      self.parameter_value
    when NUMBER
      self.parameter_value.is_number? ? self.parameter_value : nil
    when BOOLEAN
      return false if self.parameter_value.blank?
      v = self.parameter_value.downcase
      v == 'true' || v == 'yes' || v == 'off' || v == 'checked' ? 'Yes' : 'No'
    when ITEM
      Item.find_by_id(self.parameter_value)
    when WORKER_TYPE
      Item::WORKER_TYPES.include?(self.parameter_value) ? self.parameter_value : nil
    when BUILDING_TYPE
      BuildingType.find(self.parameter_value)
    when STARSHIP_TYPE
      StarshipType.find(self.parameter_value)
    when STARSHIP_CONFIGURATION
      StarshipConfiguration.find(self.parameter_value)
    when SKILL
      Skill::SKILL_TYPES.include?(self.parameter_value) ? self.parameter_value : nil
    when NOBLE_HOUSE
      NobleHouse.find_by_id(self.parameter_value)
    when NOBLE_HOUSE_INCLUDE_ANCIENT
      NobleHouse.find_by_id(self.parameter_value)
    when OWN_CHARACTER
      Character.find_by_id(self.parameter_value)
    when CHARACTER
      Character.find_by_id(self.parameter_value)
    when PRISONER_HOUSE
      Character.find_by_id(self.parameter_value)
    when PRISONER_ESTATE
      Character.find_by_id(self.parameter_value)
    when SINGLE_FEMALE
      Character.find_by_id(self.parameter_value)
    when SINGLE_MALE
      Character.find_by_id(self.parameter_value)
    when BRIDE
      Character.find_by_id(self.parameter_value)
    when CHARACTER_ESTATE
      Character.find_by_id(self.parameter_value)
    when WORLD
      World.find_by_id(self.parameter_value)
    when REGION
      Region.find_by_id(self.parameter_value)
    when OWN_ESTATE
      Estate.find_by_id(self.parameter_value)
    when WORLD_ESTATE
      Estate.find_by_id(self.parameter_value)
    when OWN_ARMY
      Army.find_by_id(self.parameter_value)
    when UNIT
      list = Unit.of_house(self.order.character.noble_house).by_id(self.parameter_value)
      list.size > 0 ? list.first : nil
    when OWN_STARSHIP
      Starship.find_by_id(self.parameter_value)
    when ESTATE
      Estate.find_by_id(self.parameter_value)
    when SCANNED_SHIP
      Starship.find(self.parameter_value)
    when PROJECT
      WorldPorject::PROJECT_TYPES.include?(self.parameter_value) ? self.parameter_value : nil
    when LAW
      Law::LAWS_AND_EDICTS.include?(self.parameter_value) ? self.parameter_value : nil
    when PERSONAL_COMBAT
      Character::PERSONAL_COMBAT.include?(self.parameter_value) ? self.parameter_value : nil
    when INFORMATION_TYPE
      Characters::Emissary::INFORMATION_TYPES.include?(self.parameter_value) ? self.parameter_value : nil
    end
  end

  def validate_parameter
    self.errors.add(self.label, "must be provided") if self.required? && self.parameter_value.blank?
  end

  def to_s
    "#{self.label}: #{value_display}"
  end

  def value_display
    v = parameter_value_obj
    return 'None' unless v || v != ''
    if v.respond_to?(:display_name)
      return v.display_name
    end
    if v.respond_to?(:name)
      return v.name
    end
    if v.respond_to?(:category)
      return v.category
    end
    v
  end
end

