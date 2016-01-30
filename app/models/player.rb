class Player < ActiveRecord::Base
  attr_accessible :guid, :name, :username, :email, :password, :password_confirmation, :confirm_code, :confirmed, :active, :email_house_news, :email_newsletter, :email_messages, :gm, :unlimited_credits, :last_house_news, :terms, :new_news_flag

  before_save   :generate_confirm_code
  before_save   :generate_guid

  acts_as_authentic
  has_one :noble_house, :dependent => :destroy

  attr_accessor :terms
  validates :terms, :acceptance => true, :if => Proc.new{|p| p.new_record? }

  scope :confirm_code, lambda {|code|
    {:conditions => {:confirm_code => code}}
  }

  scope :email_house_news, :conditions => {:email_house_news => true}
  scope :email_newsletter, :conditions => {:email_newsletter => true}

  scope :confirmed, :conditions => {:confirmed => true}
  scope :unconfirmed, :conditions => {:confirmed => false}
  scope :active, :conditions => {:active => true}
  scope :disabled, :conditions => {:active => false}

  scope :recently_active, :conditions => ['DATEDIFF(CURRENT_DATE,last_request_at) <= 1']
  scope :last_week, :conditions => ['DATEDIFF(CURRENT_DATE,last_request_at) <= 7']
  scope :awol, :conditions => ['DATEDIFF(CURRENT_DATE,last_request_at) > 7']
  scope :abandoned, :conditions => ['DATEDIFF(CURRENT_DATE,last_request_at) > 50']

  def self.gm
    find(:first, :conditions => {:gm => true})
  end

  def self.deliver_newsletter!(content)
    confirmed.email_newsletter.each{|p| p.deliver_newsletter!(content) }
  end

  def self.deliver_house_news!
    player_news = []
    confirmed.active.email_house_news.each do |p|
      if p.has_news?
        news = p.house_news_since_last_sending
        player_news << {:player => p, :news => news}
      end
    end
    player_news.each do |pn|
      pn[:player].deliver_house_news!(pn[:news])
    end
  end

  def house_news_since_last_sending
    @house_news ||= self.last_house_news ? News.home_news(self.noble_house).since(self.last_house_news || self.created_at).oldest_first : News.home_news(self.noble_house).oldest_first
  end

  def has_news?
    @has_news ||= (self.noble_house && house_news_since_last_sending.size > 0)
  end

  def read_news!
    update_attributes!(:new_news_flag => false) if self.new_news_flag
  end

  def email_with_name
    "\"#{self.name}\" <#{self.email}>"
  end

  def make_gm!
    update_attributes(:gm => true, :unlimited_credits => true)
  end

  def generate_confirm_code
    unless confirmed? or !self.confirm_code.blank?
      self.confirm_code = $UID.generate
    end
  end

  def no_email!
    update_attributes!(:email_house_news => false, :email_newsletter => false, :email_messages => false)
  end

  def confirm!
    update_attributes!(:confirm_code => nil, :confirmed => true)
  end

  def lock!
    update_attributes!(:active => false)
  end
  def unlock!
    update_attributes!(:active => true)
  end

  def top_up!(amount)
    update_attributes!(:credits => self.credits + amount)
  end

  def use_credit!
    update_attributes!(:credits => self.credits - 1) unless self.unlimited_credits
  end

  def signup_complete?
    self.confirmed? && !self.noble_house.nil?
  end

  def deliver_confirmation!
    PlayerMailer.confirm_email(self).deliver
  end

  def deliver_signup_complete!
    PlayerMailer.signup_complete(self).deliver
  end

  def deliver_house_ceased!(inherited_by)
    PlayerMailer.house_ceased(self,inherited_by).deliver if self.email_house_news
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    PlayerMailer.password_reset_instructions(self).deliver
  end

  def deliver_house_news!(news)
    if self.email_house_news
      PlayerMailer.house_news(self, news).deliver 
      update_attributes!(:last_house_news => Time.now)
    end
  end

  def deliver_newsletter!(content,edition=Game.current_date.pt)
    PlayerMailer.newsletter(self,edition,content).deliver if self.email_newsletter
  end

  def deliver_player_message!(message)
    PlayerMailer.player_message(self,message).deliver if self.email_messages
  end

  def status
    status = []
    if gm?
      status << 'GM' 
    else
      status << 'Confirmed' if confirmed?
      status << 'Locked' unless active?
      status << 'Unlimited Credits' if unlimited_credits?
      status << 'Email: House News' if email_house_news?
      status << 'Email: Newsletter' if email_newsletter?
      status << 'Email: Messages' if email_messages?
    end
    status
  end
end
