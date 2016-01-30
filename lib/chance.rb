class Chance
  attr_accessor :chance, :score, :dice, :rolled
  
  def self.read(s)
    return nil if s.blank?
    begin
      if s.include?("in")
        a = s.split(" in ")
        chance = a[0].to_i
        dice = Dice.read(a[1])
        Chance.new(chance,0,dice)
      else
        a = s.split(" on ")
        score = a[0].to_i
        dice = Dice.read(a[1])
        Chance.new(0,score,dice)
      end
    rescue
      raise "Invalid chance format"
    end
  end

  def initialize(chance = 0, score = 0, dice = Dice.new)
    @chance = chance
    @score = score
    @dice = dice
    @rolled = 0
  end

  def blank?
    chance == 0
  end

  def +(n)
    Chance.new(chance, score, (self.dice + n))
  end

  def -(n)
    Chance.new(chance, score, (self.dice - n))
  end

  def <(c)
    return false unless c
    if c.is_a?(Chance)
      (self.probability_of_success < c.probability_of_success)
    else
      (self.probability_of_success < c.to_f)
    end
  end
  
  def >(c)
    return true unless c
    if c.is_a?(Chance)
      (self.probability_of_success > c.probability_of_success)
    else
      (self.probability_of_success > c.to_f)
    end
  end

  def probability_of_success
    return @probability_of_success if @probability_of_success
    return 0 unless dice
    prob = dice.probabilities
    @probability_of_success = 0
    prob.keys.each do |hit|
      if chance && chance > 0
        @probability_of_success += prob[hit] if hit <= chance && hit != dice.min
      elsif score && score > 0
        @probability_of_success += prob[hit] if hit >= score && hit != dice.min
      end
    end
    @probability_of_success
  end

  def percentage_success
    (probability_of_success * 100).round(0).to_i
  end

  def success?
    return false unless dice
    self.rolled = dice.roll
    return false if self.rolled == dice.min
    if score > 0
      self.rolled >= score
    else
      self.rolled <= chance
    end
  end

  def to_s
    if score > 0
      "#{score} on #{dice}"
    elsif chance > 0
      "#{chance} in #{dice}"
    end
  end

  def to_pretty
    "#{to_s} (#{percentage_success}% chance)"
  end

  alias_method :pp, :to_pretty
end
