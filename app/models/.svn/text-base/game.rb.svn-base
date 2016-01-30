class Game < ActiveRecord::Base

  VERSION = "Alpha"

  attr_accessible :current_date, :updating, :dispatching

  attr_accessor :updated, :dispatched

  def after_initialize
    @updated = true
    @dispatched = false
  end
  
  game_date :current_date
  # updating
  # dispatching

  def self.current
    find(:last) || Game.create!(:current_date => GameDate.new(1,48,10))
  end

  def self.current_date
    begin
      current.current_date
    rescue
      # May be thrown during DB migration if Game table not in place yet
      Kernel.p "ERROR : GAME #{current}"
    end
  end

  def self.new_year?
    current_date.chronum == 1
  end

  def self.game_locked?
    current.updating? || current.dispatching?
  end

  def self.updating!
    current.updated = false
    current.dispatched = false
    current.update_attributes!(:updating => true)
  end

  def self.dispatching!
    current.updated = false
    current.dispatched = false
    current.update_attributes!(:dispatching => true)
  end

  def self.game_lock!
    current.update_attributes!(:updating => true)
  end

  def self.game_unlock!
    current.updated = current.updating
    current.dispatched = current.dispatching
    current.update_attributes!(:updating => false, :dispatching => false)
  end
  
  def next_chronum!
    self.updated = false
    self.dispatched = false
  	self.current_date = self.current_date + 1
  	save!
  	self.current_date
	end

  def newsletter_filename
    "#{Rails.root}/public/newsletters/#{current_date.pt}.html"
  end

  def save_newsletter(content)
    File.open(newsletter_filename, 'w') {|f| f.write(content) }
  end

  def load_newsletter
    content = nil
    File.open(newsletter_filename, 'r') {|f| content =  f.read }
    content
  end

end
