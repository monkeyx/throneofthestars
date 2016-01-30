class Ransom < ActiveRecord::Base
  attr_accessible :character, :offered_date, :prisoner, :ransom
  
  belongs_to :character
  game_date :offered_date
  belongs_to :prisoner
  validates_numericality_of :ransom
  
  def self.ransom!(character,prisoner,ransom)
    return false unless character && prisoner && ransom && prisoner.estate && prisoner.estate.lord
    ransom = character.noble_house.has_funds?(ransom) ? ransom : character.noble_house.wealth
    character.noble_house.subtract_wealth!(ransom)
    r = create!(:character => character, :prisoner => prisoner, :ransom => ransom, :offered_date => Game.current_date)
    character.add_news!('RANSOM_OFFER',r.target_description)
    prisoner.estate.lord.add_news!('RANSOM_OFFER_RECEIVED',r.target_description)
    r.accept! if prisoner.noble_house.ancient? && ransom >= 5000
    true
  end

  def accept!
    prisoner.noble_house.add_wealth!(self.ransom)
    character.add_news!('RANSOM_ACCEPTED',target_description)
    prisoner.estate.lord.add_news!('RANSOM_ACCEPT',target_description)
    destroy
  end

  def reject!
    self.character.noble_house.add_wealth!(self.ransom)
    character.add_news!('RANSOM_REJECTED',target_description)
    destroy
  end

  def target_description
    "for #{prisoner.character.display_name} of &pound;#{ransom}"
  end

end
