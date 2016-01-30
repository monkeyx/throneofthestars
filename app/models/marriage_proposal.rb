class MarriageProposal < ActiveRecord::Base
  attr_accessible :character, :character_id, :target, :target_id, :dowry, :proposal_date
  
  belongs_to :character
  belongs_to :target, :class_name => 'Character'
  validates_numericality_of :dowry
  game_date :proposal_date

  scope :from, lambda {|character|
    {:conditions => {:character_id => character.id}}
  }
  scope :to, lambda {|character|
    {:conditions => {:target_id => character.id}}
  }

  def self.proposal!(from,to,dowry=0.0)
    raise "#{from.name} cannot be married" unless from.can_marry?
    raise "#{to.name} cannot be married" unless to.can_marry?
    transaction do
      mp = find(:first, :conditions => {:character_id => from.id, :target_id => to.id})
      mp = create!(:character_id => from.id, :target_id => to.id, :proposal_date => Game.current_date, :dowry => 0) unless mp
      if mp.dowry && mp.dowry > 0
        dowry = from.noble_house.wealth unless from.noble_house.has_funds?(dowry)
        from.noble_house.subtract_wealth!(dowry)  
        mp.dowry = dowry
      end
      mp.save!
      if to.noble_house.ancient? || to.same_house?(from)
        mp.accept! 
        from.reload
        to.reload
        from.marry!
      end
      mp
    end
  end

  def reject!
    self.character.noble_house.add_wealth!(self.dowry) if self.character.noble_house && self.dowry > 0
    destroy
  end

  def accept!
    transaction do
      self.target.noble_house.add_wealth!(self.dowry) if self.target.noble_house && self.dowry && self.dowry > 0
      self.character.betrothed!(self.target)
      MarriageProposal.from(character).each{|proposal| proposal.destroy}
      MarriageProposal.to(target).each{|proposal| proposal.destroy}
    end
  end
end
