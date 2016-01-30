module Characters
  module Marriage
    def propose!(other_character,dowry)
      MarriageProposal.proposal!(self,other_character,dowry)
      add_news!("PROPOSAL",other_character)
      other_character.add_news!("PROPOSED",self)
      true
    end

    def betrothed!(betrothed)
      update_attributes!(:betrothed => betrothed)
      betrothed.update_attributes!(:betrothed => self)
      if male?
        add_news!("BETROTHED_MALE",betrothed)
        betrothed.add_news!("BETROTHED_FEMALE",self)
      else
        add_news!("BETROTHED_FEMALE",betrothed)
        betrothed.add_news!("BETROTHED_MALE",self)
      end
      true
    end

    def break_betrothal!
      return false unless self.betrothed
      honour_loss = (self.betrothed.noble_house.honour * 0.1).round(0).to_i
      piety_loss = (self.betrothed.noble_house.piety * 0.1).round(0).to_i
      wedding = Wedding.of(self).first
      wedding.cancel!("#{self.name} broke the betrothal") if wedding
      honour_loss = lose_honour!(honour_loss).to_i
      piety_loss = lose_piety!(piety_loss).to_i
      if noble?
        add_empire_news!('BROKE_BETROTHAL',self.betrothed)
      else
        add_news!('BROKE_BETROTHAL',self.betrothed)
      end
      self.betrothed.add_news!('BETROTHAL_BROKEN',self)
      self.betrothed.betrothed = nil
      self.betrothed.save!
      self.betrothed = nil
      save!
    end

    def marry!
      return false unless is_betrothed?
      transaction do
        self.spouse = self.betrothed
        self.spouse.spouse = self
        self.betrothed = nil
        self.spouse.betrothed = nil
        self.spouse.save!
        save!
        if male?
          news_code = 'MARRIED_HUSBAND'
          spouse_news_code = 'MARRIED_WIFE'
        else
          news_code = 'MARRIED_WIFE'
          spouse_news_code = 'MARRIED_HUSBAND'
        end
        if noble?
          add_empire_news!(news_code,self.spouse)
        else
          add_news!(news_code,self.spouse)
        end
        self.spouse.add_news!(spouse_news_code,self)
        self.spouse.move_to_estate!(self.current_estate || self.noble_house.home_estate, true)
        self.titles.each{|title| title.give_wife_title!}
        true
      end
    end
  end
end
