module StringExtensions
  def dice
    Dice.read(self)
  end

  def roll
    dice.roll
  end

  def chance
    Chance.read(self)
  end

  def success?
    chance.success?
  end

  def gamedate
    GameDate.read(self)
  end

  def is_number?
    true if Float(self) rescue false
  end

  def pluralize_if(quantity)
    return pluralize if quantity == 0 || quantity > 1
    self
  end
end

class String
  include StringExtensions
end