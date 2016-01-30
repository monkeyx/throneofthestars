class WeddingInvite < ActiveRecord::Base
  attr_accessible :wedding, :character, :sent_date, :accepted_date, :attended

  belongs_to :wedding
  belongs_to :character
  game_date :sent_date
  game_date :accepted_date
  # attended

  def attended!
    update_attributes!(:attended => true)
  end
end
