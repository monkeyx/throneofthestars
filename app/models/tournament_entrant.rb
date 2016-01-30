class TournamentEntrant < ActiveRecord::Base
  attr_accessible :tournament, :character, :joined_date
  
  belongs_to :tournament
  belongs_to :character
  game_date :joined_date
end
