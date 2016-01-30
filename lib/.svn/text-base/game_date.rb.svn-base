class GameDate
  include Comparable
  attr_accessor :age, :year, :chronum
  
  def self.read(s)
  	return nil if s.blank?
  	begin
      parts = s.split("::")
      new(parts[0].to_i,parts[1].to_i,parts[2].to_i)
	 	rescue
	 		raise "Invalid game date format"
		end
  end
  
  def initialize(age = 1, year = 1, chronum = 1)
    @age = age
    @year = year
    @chronum = chronum
    @chronum = 1 if @chronum < 1
    @chronum = 10 if @chronum > 10
  end
  
  def <(d) # self before d
    self.age > d.age || self.year > d.year || (self.year == d.year && self.chronum > d.chronum)
  end
  
  def >(d) # self after d
    self.age < d.age || self.year < d.year || (self.year == d.year && self.chronum < d.chronum)
  end
  
  def ==(d)
    !d.nil? && d.class == self.class && self.age == d.age && self.year == d.year && self.chronum == d.chronum
  end
  
  def <=>(d)
  	(self.year * 10 + self.chronum) <=> (d.year * 10 + d.chronum)
	end
  
  def +(c)
    total_chronum = (self.year * 10) + (self.chronum) + c
    y = ((total_chronum - 1) / 10).to_i
    chr = total_chronum - (y * 10)
    GameDate.new(self.age,y,chr)
  end
  
  def -(c)
    self.+(0 - c)
  end
  
  def difference(d)
    raise "Cannot compare dates of different Ages" if self.age != d.age 
    if self < d
      0 - ((d.year - self.year) * 10 + (d.chronum - self.chronum))
    else
      (self.year - d.year) * 10 + (self.chronum - d.chronum)
    end 
  end

  def past?(d)
    self == d || self > d
  end

  def future?(d)
    self < d
  end

  def years_ago
    (Game.current_date.difference(self) / 10).to_i
  end

  def eql?(o)
    self == o
  end

  def hash
    to_s.hash
  end

  def padded_year
    "%05d" % self.year
  end

  def padded_chronum
    "%02d" % self.chronum
  end

  def padded_age
    "%03d" % self.age
  end
  
  def to_s
    "#{padded_age}::#{padded_year}::#{padded_chronum}"
  end

  def pp
    to_pretty
  end

  def pt
    to_pretty_text
  end

  def to_pretty
    (self.age > 1 ? "#{self.chronum.ordinalize} &empty; #{self.year.ordinalize} &forall;, #{self.age.ordinalize} &part;".html_safe : "#{self.chronum.ordinalize} &empty; #{self.year.ordinalize} &forall;".html_safe)
  end

  def to_pretty_text
    (self.age > 1 ? "#{self.chronum.ordinalize} Chronum #{self.year.ordinalize} Year, #{self.age.ordinalize} Age" : "#{self.chronum.ordinalize} Chronum #{self.year.ordinalize} Year")
  end
end  
