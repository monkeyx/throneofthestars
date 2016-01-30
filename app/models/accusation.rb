class Accusation < ActiveRecord::Base
  attr_accessible :character, :accused, :accusation_date, :response, :response_date, :combat_type, :judged_against
  
  NONE = ''
  REJECT = 'Rejected'
  TRIAL_COMBAT = 'Trial By Combat'
  TRIAL_CHURCH = 'Church Trial'
  TRIAL_COURT = 'Court Trial'

  RESPONSE_TYPES = [NONE, REJECT, TRIAL_COMBAT, TRIAL_CHURCH, TRIAL_COURT]
  AUTO_REJECT_TYPES = [NONE, TRIAL_CHURCH, TRIAL_COURT]

  belongs_to :character
  belongs_to :accused, :class_name => 'Character'
  belongs_to :judged_against, :class_name => 'Character'
  game_date :accusation_date
  validates_inclusion_of :response, :in => RESPONSE_TYPES
  game_date :response_date

  scope :concerning, lambda {|character|
    {:conditions => ["character_id = ? OR accused_id = ?",character.id, character.id]}
  }

  scope :accused, lambda {|character|
    {:conditions => {:accused_id => character.id}}
  }

  scope :court_trial, :conditions => {:response_type => TRIAL_COURT}
  scope :church_trial, :conditions => {:response_type => TRIAL_CHURCH}

  def self.resolutions!
    transaction do
      all.each do |accusation|
        accusation.reject! if AUTO_REJECT_TYPES.include?(accusation.response) && (Game.current_date - 10) < accusation.accusation_date
        accusation.resolve!
      end
    end
  end

  def self.find_accusation(character, source)
    find_by_character_id_and_accused_id(source.id, character.id)
  end

  def self.accuse!(character,target)
    return false unless character && target && character.noble_house_id != target.noble_house_id
    return false if find_by_character_id_and_accused_id(character.id, target.id)
    accusation = create!(:character => character, :accused => target, :accusation_date => Game.current_date)
    character.add_empire_news!('ACCUSATION',target)
    target.add_news!('ACCUSED',character)
    accusation
  end

  def reject!
    respond!(REJECT)
  end

  def trial_by_combat!(combat_type)
    respond!(TRIAL_COMBAT,combat_type)
  end

  def trial_by_church!
    respond!(TRIAL_CHURCH)
  end

  def trial_by_court!
    respond!(TRIAL_COURT)
  end

  def judge_against!(character)
    return false unless ((self.character && self.character_id == character.id) || self.accused == accused) && (self.response_type == TRIAL_COURT || self.response_type == TRIAL_CHURCH)
    update_attributes!(:judged_against => character)
  end

  def respond!(response_type,combat_type=nil)
    case response_type
    when REJECT
      self.character.add_news!('REJECT_ACCUSATION',self.accused)
    when TRIAL_COMBAT
      self.character.add_news!('TRIAL_COMBAT',self.accused)
    when TRIAL_CHURCH
      if Law.church_trials?
        self.character.add_news!('TRIAL_CHURCH',self.accused) 
      else
        return
      end
    when TRIAL_COURT
      if Law.court_trials?
        self.character.add_news!('TRIAL_COURT',self.accused) 
      else
        return
      end
    end
    update_attributes!(:response => response_type, :response_date => Game.current_date, :combat_type => combat_type)
  end

  def wrong_party
    if judged_against
      if judged_against.id == character_id
        return accused
      else
        return character
      end
    end
    nil
  end

  def resolve!
    case self.response
    when REJECT
      DiplomaticRelation.cassus_belli!(self.character.noble_house,self.accused.noble_house,DiplomaticRelation::INJUSTICE)
      destroy
    when TRIAL_COMBAT
      winner = character.personal_combat!(accused, combat_type)
      if winner.id == character_id
        loser = accused
      else
        loser = character
      end
      DiplomaticRelation.cassus_belli!(loser.noble_house,winner.noble_house,DiplomaticRelation::TRIAL) if loser.dead?
      destroy
    when TRIAL_CHURCH
      if judged_against
        DiplomaticRelation.cassus_belli!(wronged_party.noble_house,judged_against.noble_house,DiplomaticRelation::TRIAL)
        destroy
      end
    when TRIAL_COURT
      if judged_against
        DiplomaticRelation.cassus_belli!(wronged_party.noble_house,judged_against.noble_house,DiplomaticRelation::TRIAL)
        destroy
      end
    end
  end
end
