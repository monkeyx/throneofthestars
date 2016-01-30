class Prisoner < ActiveRecord::Base
  attr_accessible :noble_house, :estate, :character, :captured_date
  
  belongs_to :noble_house
  belongs_to :estate
  belongs_to :character
  game_date :captured_date

  has_many :ransoms, :dependent => :destroy

  def self.cleanup!
    all.each do |prisoner|
      prisoner.destroy unless prisoner.character.at_same_estate?(prisoner.estate)
    end
  end

  def self.imprison!(character,estate,rightful=true)
    p = create!(:noble_house => estate.noble_house, :estate => estate, :character => character, :captured_date => Game.current_date)
    if character.clergy?
      character.add_church_news!("IMPRISONED", estate)
    else
      character.add_empire_news!("IMPRISONED", estate)
    end
    unless rightful || character.noble_house_id == p.noble_house_id
      honour = (character.noble_house.honour / 10.0).round(0).to_i
      p.noble_house.lose_honour!(honour)
      DiplomaticRelation.cassus_belli!(character.noble_house,p.noble_house,DiplomaticRelation::IMPRISONMENT)
    end
    character.apprenticeship.end!(false) if character.apprenticeship
    p
  end

  def release!
    if character.clergy?
      character.add_church_news!("RELEASED", estate)
    else
      character.add_empire_news!("RELEASED", estate)
    end
    honour = (character.noble_house.honour / 10.0).round(0).to_i
    if honour > 0
      noble_house.add_honour!(honour) 
      character.noble_house.lose_honour!(honour)
    end
    self.character.move_to_nearest_estate!
    self.ransoms.each do |r| 
      r.accept!
    end
    destroy
  end

  def execute!
    transaction do
      honour = (noble_house.honour / 10.0).round(0).to_i
      noble_house.lose_honour!(honour)
      if character.clergy?
        character.add_church_news!("EXECUTED", estate)
      else
        character.add_empire_news!("EXECUTED", estate)
      end
      self.character.die!("public execution")
      if self.character.related?(self.noble_house.baron)
        self.noble_house.baron.add_trait!(Trait::SPECIAL_KINSLAYER)
      end
      destroy
    end
  end

  def check_for_escape!
    case "1d10".roll
    when 1
      if character.clergy?
        character.add_church_news!("ESCAPE_FAIL", estate)
      else
        character.add_empire_news!("ESCAPE_FAIL", estate)
      end
      self.character.die!("a failed escape attempt")
      destroy
    when 10
      if character.clergy?
        character.add_church_news!("ESCAPE_SUCCESS", estate)
      else
        character.add_empire_news!("ESCAPE_SUCCESS", estate)
      end
      self.ransoms.each{|ransom| ransom.reject! }
      self.character.move_to_nearest_estate!
      destroy
    end
  end
end
