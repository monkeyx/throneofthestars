class Scan < ActiveRecord::Base
  attr_accessible :starship, :world, :target, :scan_date
  
  belongs_to :starship
  belongs_to :world
  belongs_to :target, :class_name => 'Starship'
  game_date :scan_date

  scope :at, lambda {|world|
    {:conditions => {:world_id => world.id}, :order => 'id ASC'}
  }

  scope :by, lambda {|starship|
    {:conditions => {:starship_id => starship.id}}
  }

  scope :by_house, lambda {|house|
    {:conditions => ["starship_id IN (?)", house.starships]}
  }

  scope :of, lambda {|starship|
    {:conditions => {:target_id => starship.id}}
  }

  scope :of_house, lambda {|house|
    {:conditions => ["target_id IN (?)", house.starships]}
  }

  def self.scanned!(starship, target, world)
    scan = create!(:starship => starship, :target => target, :world => world, :scan_date => Game.current_date)
    desc = target.debris? ? "Debris" : target.starship_configuration.name
    starship.add_news!("SCANNED","#{target.noble_house.name} #{target.name} [#{desc}] in orbit of #{world.name}")
    scan
  end

  def self.expire_old!
    all.each{|scan| scan.destroy if scan.old?}
  end

  def recent?
    self.scan_date == Game.current_date
  end

  def old?
    self.scan_date > Game.current_date
  end

end
