module Events
  def self.all_events
    (Tournament.all + Wedding.all).sort{|a,b| a.event_date <=> b.event_date }
  end

  def self.all_now
    (Tournament.now + Wedding.now).sort{|a,b| a.event_date <=> b.event_date }
  end

  def self.now(estate)
    (Tournament.at(estate) + Wedding.at(estate)).sort{|a,b| a.event_date <=> b.event_date }
  end

  def self.all_pending
    (Tournament.pending + Wedding.pending).sort{|a,b| a.event_date <=> b.event_date }
  end

  def self.all_pending_or_now
    (Tournament.pending_or_now + Wedding.pending_or_now).sort{|a,b| a.event_date <=> b.event_date }
  end

  def self.all_pending_at(estate)
    (Tournament.pending_at(estate) + Wedding.pending_at(estate)).sort{|a,b| a.event_date <=> b.event_date }
  end

  def past?
    Game.current_date < self.event_date
  end

  def now?
    Game.current_date == self.event_date
  end

  def pending?
    Game.current_date > self.event_date
  end

  def at_location?(character)
    character.current_estate && character.current_estate.id == self.estate_id
  end

  def css_class
    return "now" if now?
    return "future" if pending?
    "past"
  end
    
end
