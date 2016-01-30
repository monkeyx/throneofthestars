class Dice
  require 'polynomial'

  include Comparable
  attr_accessor :n, :d, :m
  
  def self.read(s)
    return nil if s.blank?
    begin
      a = s.include?("+") ? s.split("+") : (s.include?("-") ? s.split("-") : [s])
      b = a[0].split("d")
      n = b[0].to_i
      d = b[1].to_i
      if a.length > 1
        m = s.include?("+") ? m = a[1].to_i : m = 0 - a[1].to_i
      else
        m = 0
      end
      Dice.new(n,d,m)
    rescue
      raise "Invalid dice notation"
    end
  end
  
  def initialize(n = 0, d = 0, m = 0)
    @n = n
    @d = d
    @m = m
  end

  def blank?
    n == 0 || d == 0
  end
  
  def <(d)
    if d.is_a?(Dice)
      (self.average < d.average)
    else
      (self.average < d.to_f)
    end
  end
  
  def >(d)
    if d.is_a?(Dice)
      (self.average > d.average)
    else
      (self.average > d.to_f)
    end
  end
  
  def ==(d)
    (self.d == d.d) && (self.n == d.n) && (self.m == d.m)
  end
  
  def <=>(d)
    self.average <=> d.average
	end
  
  def +(d)
    if d.respond_to?(:roll)
      if d.d == self.d
        Dice.new((self.n + d.n), self.d, (self.m + d.m))
      else
        Dice.new((self.n), self.d, (self.m + d.average))
      end
    else
      Dice.new((self.n), self.d, (self.m + d))
    end
  end
  
  def -(d)
    if d.respond_to?(:roll)
      if d.d == self.d
        Dice.new((self.n - d.n), self.d, (self.m - d.m))
      else
        Dice.new((self.n), self.d, (self.m - d.average))
      end
    else
      Dice.new((self.n), self.d, (self.m - d))
    end
  end

  def average
    apd = sum_possibilities / d.to_f
    ((apd * n) + m)
  end

  def max
    (n * d) + m
  end

  def min
    n + m
  end

  def roll
    t = 0
    n.times{ t += (rand(d) + 1)}
    t + m
  end
  
  def to_s
    m == 0 ? "#{self.n}d#{self.d}" : (m > 0 ? "#{self.n}d#{self.d}+#{self.m}" : "#{self.n}d#{self.d}-#{self.m.abs}")
  end

  def probabilities
    return @probabilities if @probabilities
    @probabilities = {}
    min = n
    max = n * d
    combinations = 1 * d**n

    polys = []

    (1..n).each do |r|
      polys.push(Polynomial.mkroll(d))
    end

    biggun = Polynomial.new([1]) #identity

    polys.each do |p|
      biggun *= p
    end

    (min..max).each do |deg|
      coeff = biggun.coefficients[deg]
      if !(coeff.nil? or coeff == 0)
        px = coeff.to_f / combinations.to_f
        @probabilities[(deg + m)] = px
      end
    end
    @probabilities
  end

  private
  def sum_possibilities
    t = 0
    d.times{|x| t += (x+1)}
    t
  end
end  
