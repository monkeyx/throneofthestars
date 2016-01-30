module Wealthy
  include NumberFormatting
  
  def add_wealth!(amount)
    update_attributes!(:wealth => self.wealth + amount)
  end

  def subtract_wealth!(amount)
    update_attributes!(:wealth => self.wealth - amount)
  end

  def transfer_funds!(to,amount,reason=nil)
    amount = self.wealth if amount > self.wealth
    to.add_wealth!(amount)
    if reason && to.respond_to?(:add_news!)
      to.add_news!("CASH_TRANSFER","#{money(amount)} for #{reason}")
  end
    self.subtract_wealth!(amount)
    amount
  end

  def funds_for(price)
    (self.wealth / price).to_i
  end

  def has_funds?(amount)
    self.wealth >= amount
  end

  module NobleHousePosition
    include NumberFormatting

    def wealth
      self.noble_house.wealth
    end
    
    def add_wealth!(amount)
      self.noble_house.add_wealth!(amount)
    end

    def subtract_wealth!(amount)
      self.noble_house.subtract_wealth!(amount)
    end

    def funds_for(price)
      self.noble_house.funds_for(price)
    end

    def has_funds?(amount)
      self.noble_house.has_funds?(amount)
    end

    def transfer_funds!(to,amount,reason=nil)
      self.noble_house.transfer_funds!(to,amount,reason)
    end
  end
end
