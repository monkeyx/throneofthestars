class Message < ActiveRecord::Base
  attr_accessible :guid, :character, :character_id, :from, :from_id, :sent_date, :reply_to, :reply_to_id, :subject, :sovereigns, :content, :archived, :internal, :reported

  before_save :format_message
  before_save :generate_guid  

  attr_accessor :internal

  self.per_page = 15

  EMOTICONS = {
    ':)' => '/assets/emoticons/smile.png',
    ':(' => '/assets/emoticons/unhappy.png',
    ':o' => '/assets/emoticons/surprised.png',
    ':p' => '/assets/emoticons/tongue.png',
    ';)' => '/assets/emoticons/wink.png',
    ':D' => '/assets/emoticons/happy.png'
  }
  
  belongs_to :character
  validates_presence_of :character_id
  belongs_to :from, :class_name => 'Character'
  validates_presence_of :from_id
  game_date :sent_date
  belongs_to :reply_to, :class_name => 'Message'
  validates_presence_of :subject
  validates_numericality_of :sovereigns
  # validates :content, :length => {:maximum => 4096}

  # content
  # formatted_content

  validates_with MessageValidator

  scope :to, lambda {|character|
    {:conditions => {:character_id => character.id}, :order => 'created_at DESC'}
  }

  scope :from, lambda {|character|
    {:conditions => {:from_id => character.id}, :order => 'created_at DESC'}
  }

  scope :replies, lambda {|message|
    {:conditions => {:reply_to_id => message.id}, :order => 'created_at DESC'}
  }

  scope :not_archived, :conditions => ['archived IS NULL or archived = 0']
  scope :archived, :conditions => {:archived => true}

  scope :not_reported, :conditions => ['reported IS NULL or reported = 0']
  scope :reported, :conditions => {:reported => true}

  def self.send_internal!(from, subject, content, to=from.noble_house.baron)
    msg = create!(:from => from, :character => to, :subject => subject, :content => content, :internal => true)
    msg.action!
  end

  def self.send_from_gm!(to, subject, content, sovereigns=0)
    msg = create!(:from => Player.gm.noble_house.baron, :character => to.noble_house.baron, :subject => subject, :content => content, :internal => true, :sovereigns => sovereigns)
    msg.action!
  end

  def self.message_count(character)
    find_by_sql("SELECT count(*) AS message_count FROM messages WHERE character_id = #{character.id} AND (archived IS NULL OR archived = 0) AND (reported IS NULL OR reported = 0)").first.message_count
  end

  def self.image_emoticons(content)
    EMOTICONS.keys.each do |emoticon|
      image = EMOTICONS[emoticon]
      content = content.gsub(emoticon, "<img src='#{image}' alt='#{emoticon}'/>")
    end
    content
  end

  def self.styled_quotes(content)
    content = content.gsub('<blockquote>',"<blockquote><span>")
    content = content.gsub('</blockquote>',"</span></blockquote>")
    content
  end

  def cash_enclosed?
    self.sovereigns && self.sovereigns > 0
  end
  
  def format_message
    self.sent_date = Game.current_date unless self.sent_date
    unless self.content.nil?
      self.formatted_content = Message.styled_quotes(Message.image_emoticons(self.content.bbcode_to_html))
    else
      self.formatted_content = '' 
    end
  end

  def action!
    self.sovereigns = self.from.noble_house.wealth if self.from && self.from.noble_house.wealth < self.sovereigns
    if self.sovereigns && self.sovereigns > 0
      self.character.noble_house.add_wealth!(self.sovereigns)
      self.from.noble_house.subtract_wealth!(self.sovereigns)
    end
    self.character.noble_house.player.deliver_player_message!(self) if !self.internal && self.character && self.character.noble_house && self.character.noble_house.player
    true
  end

  def reply
    c = self.content.gsub('[quote]','')
    c = c.gsub('[/quote]','')
    c = "[quote]#{c}[/quote]"
    if self.from.baron?
      to = self.from 
    else
      to = self.from.noble_house.baron
    end
    Message.new(:character => to, :from => self.character, :subject => "RE: #{self.subject}", :content => c, :sovereigns => 0, :reply_to => self)
  end

  def archive!
    update_attributes!(:archived => true)
  end

  def reported!
    update_attributes!(:reported => true)
  end

end