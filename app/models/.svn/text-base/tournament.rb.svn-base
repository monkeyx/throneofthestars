class Tournament < ActiveRecord::Base

  attr_accessible :estate, :winner, :runner_up1, :runner_up2, :event_date, :prize

  COMBAT_TYPES = [Character::SWORD_FIGHT,Character::LANCE_FIGHT]

  belongs_to :estate
  belongs_to :winner, :class_name => 'Character'
  belongs_to :runner_up1, :class_name => 'Character'
  belongs_to :runner_up2, :class_name => 'Character'
  game_date :event_date
  validates_numericality_of :prize

  has_many :tournament_entrants, :dependent => :destroy
  
  scope :at, lambda {|estate|
    {:conditions => {:estate_id => estate.id}}
  }

  scope :now, :conditions => {:event_date => Game.current_date}

  include Events

  def self.pending
    all.select{|event| event.pending? }
  end

  def self.pending_or_now
    all.select{|event| event.pending? || event.now? }
  end

  def self.pending_at(estate)
    at(estate).select{|event| event.pending? }
  end

  def self.hold!(estate,event_date,prize)
    transaction do
      prize = estate.noble_house.wealth unless estate.has_funds?(prize)
      estate.subtract_wealth!(prize)
      tournament = create!(:estate => estate, :event_date => event_date, :prize => prize)
      desc = "on the #{event_date.to_pretty}"
      if prize > 0
        prize = prize.to_i if prize.round(0) == prize.to_i
        desc = desc + " with a prize fund of &pound;#{prize}" 
      end
      desc = desc + ". It is located in #{estate.region.name} on #{estate.region.world.name}."
      estate.add_empire_news!('HOLD_TOURNAMENT',desc)
      tournament
    end
  end

  def entrants_present
    @entrants_present ||= Character.at(self.estate).entrants(self)
  end

  def entrant?(character)
    self.tournament_entrants.count(:conditions => {:character_id => character.id}) > 0
  end

  def join!(character)
    return false if entrant?(character)
    entrant = self.tournament_entrants.create!(:character => character, :joined_date => Game.current_date)
    character.add_news!('JOIN_TOURNAMENT',estate)
    entrant
  end

  def valid_entrants?
    other_house_characters = 0
    self.tournament_entrants.each do |entrant| 
      other_house_characters += 1 if entrant.character.alive? && entrant.character.noble_house_id != self.estate.noble_house_id
    end
    other_house_characters > 1
  end

  def happen!
    return unless now?
    transaction do
      clean_up_participants!
      reload
      unless valid_entrants?
        self.estate.add_wealth!(self.prize)
        glory_loss = (self.estate.noble_house.glory.to_f * 0.1).round(0).to_i
        self.estate.noble_house.lose_glory!(glory_loss)
        destroy
        return
      end
      entrants = self.tournament_entrants.to_a.map{|entrant| entrant.character}
      @round_report = []
      round = 1
      runner_up = nil
      combat_type_index = 0
      while entrants.size > 1 do
        entrants, runners_up = fight_round!(entrants,COMBAT_TYPES[combat_type_index],round)
        if entrants.size == 2
          # determine third place
          if runners_up.size == 1
            self.runner_up2 = runners_up.first
          elsif runners_up.size == 0
            # no third place
          else
            play_offs, losers = fight_round!(runners_up,COMBAT_TYPES[combat_type_index],"Play Offs")
            self.runner_up2 = play_offs.first
          end
        elsif entrants.size == 1
          self.runner_up1 = runners_up.first
          self.winner = entrants[0]
        end
        round += 1
        combat_type_index += 1
        combat_type_index = 0 unless combat_type_index < COMBAT_TYPES.length
      end
      runner_up1 = runner_up2 if runner_up1 && runer_up1.dead?
      runner_up1 = nil if runner_up1 && runer_up1.dead?
      runner_up2 = nil if runner_up2 && runner_up2.dead?
      runner_up2_prize = self.runner_up2 ? (self.prize * 0.1).to_i : 0
      runner_up1_prize = self.runner_up1 ? (self.prize * 0.3).to_i : 0
      winner_prize = self.winner ? (self.prize * 0.6).to_i : 0
      unwon_prize = self.prize - winner_prize - runner_up1_prize - runner_up2_prize
      self.estate.add_wealth!(unwon_prize)
      if self.winner
        self.winner.add_wealth!(winner_prize) 
        Title.win_knighthood!(winner,estate.region) unless winner.knight?
        self.winner.add_empire_news!('TOURNAMENT_WON',self.estate)
        self.estate.lord.add_glory!((self.prize / 100).to_i)
        self.winner.add_glory!((winner_prize / 100).to_i) if winner_prize > 0
      end
      if self.runner_up1
        self.runner_up1.add_wealth!(runner_up1_prize) 
        self.runner_up1.add_news!('TOURNAMENT_RUNNER_UP', self.estate)
        self.runner_up1.add_glory!((runner_up1_prize / 100).to_i) if runner_up1_prize > 0
      end
      if self.runner_up2
        self.runner_up2.add_wealth!(runner_up2_prize) 
        self.runner_up2.add_news!('TOURNAMENT_RUNNER_UP', self.estate)
        self.runner_up2.add_glory!((runner_up2_prize / 100).to_i) if runner_up2_prize > 0
      end
      save!
      send_report!
    end
  end

  def cancel!
    return unless pending?
    transaction do
      self.estate.add_wealth!(self.prize)
      destroy
    end
  end

  def send_report!
    return false unless estate.lord
    characters = Character.at(estate) + self.tournament_entrants.map{|te| te.character}
    houses = characters.map{|c| c.noble_house }.select{|h| !h.ancient?}.uniq
    r = report
    houses.each do |house|
      Message.send_internal!(estate.lord, "Tournament at Estate #{estate.name}", 
        r, house.baron)
    end
    true
  end

  def injury_report
    r = "[b]Casaulties of the Tourney[/b]\n\n"
    injury_count = 0
    self.tournament_entrants.each do |te|
      c = te.character
      r = r + "#{c.display_name} was injured\n" if c.injured?
      r = r + "#{c.display_name} was wounded\n" if c.wounded?
      r = r + "#{c.display_name} was killed\n" if c.dead?
      injury_count += 1 if c.injured? || c.wounded? || c.dead?
    end
    r = r + "All participants were unharmed.\n" if injury_count < 1
    r
  end

  def report
    r = "[b]Estate #{estate.name} Tourney Held[/b]\n\n"
    r = r + @round_report.join("\n") + "\n" + injury_report + "\n"
    r = r + "[b]Tourmanent Winner: #{winner.display_name}[/b]\n\n"
    r = r + "[b]Runners Up:[/b]\n"
    if runner_up1
      r = r + runner_up1.display_name + "\n"
      r = r + runner_up2.display_name + "\n" if runner_up2
    else
      r = "None\n"
    end
    r
  end

  def clean_up_participants!
    self.tournament_entrants.each{|entrant| entrant.destroy unless entrant.character.alive? && at_location?(entrant.character)}
  end

  def fight_round!(entrants, combat_type,round)
    i = 0
    r = "[b]Round #{round}: Discipline #{combat_type}[/b]\n\n"
    winners = []
    runners_up = []
    number_entrants = entrants.length
    while i < number_entrants
      j = i + 1
      a = entrants[i]
      b = entrants[j] if j < number_entrants
      if a && b
        # fight!
        winner = a.personal_combat!(b, combat_type)
        winner.reload
        loser = winner.id == a.id ? b : a
        loser.reload
        r = r + "#{winner.display_name} bested #{loser.display_name}"
        r = r + " in mortal combat" unless loser.alive?
        r = r + ".\n"
        runners_up << loser if loser.alive?
        winners << winner
      else
        winners << a
      end
      a = nil
      b = nil
      i += 2
    end
    @round_report << r
    return [winners,runners_up]
  end
end
