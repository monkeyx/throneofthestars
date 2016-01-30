class News < ActiveRecord::Base
  attr_accessible :noble_house, :source, :target, :source_type, :source_id, :target_type, :target_id, :news_date, :code, :church, :empire, :description, :system_error

  before_save :set_description

  belongs_to :noble_house

  BIRTHS = ['BORN', 'BORN_BOY','BORN_GIRL']
  DEATHS = ['DIED']
  MATURED = ['NOVICE', 'NOVICE_BOY','NOVICE_GIRL']
  MARRIAGES = ['MARRIED','MARRIED_HUSBAND','BETROTHED','BETROTHED_MALE','BROKE_BETROTHAL']

  ANNOUNCEMENTS = BIRTHS + DEATHS + MATURED + MARRIAGES

  DEFAULT_NEWS_ORDERING = 'news_date DESC, id DESC'

  scope :announcements, :conditions => ["code IN (?)",ANNOUNCEMENTS], :limit => 50, :order => DEFAULT_NEWS_ORDERING
  scope :births, :conditions => ["code IN (?)",BIRTHS], :limit => 50, :order => DEFAULT_NEWS_ORDERING
  scope :matured, :conditions => ["code IN (?)",MATURED], :limit => 50, :order => DEFAULT_NEWS_ORDERING
  scope :marriages, :conditions => ["code IN (?)",MARRIAGES], :limit => 50, :order => DEFAULT_NEWS_ORDERING
  scope :deaths, :conditions => ["code IN (?)",DEATHS], :limit => 50, :order => DEFAULT_NEWS_ORDERING

  scope :of_house, lambda {|noble_house|
    {:conditions => {:noble_house_id => noble_house.id}, :limit => 50, :order => DEFAULT_NEWS_ORDERING}
  }

  scope :since, lambda {|last_sent|
    {:conditions => ['created_at > ?', last_sent]}
  }

  scope :about, lambda {|about|
    {:conditions => ["(source_id = ? AND source_type = ?) OR (target_id = ? AND target_type =?)",about.id, about.class.name, about.id, about.class.name], 
      :order => DEFAULT_NEWS_ORDERING, :limit => 50}
  }
  scope :public, :conditions => "church = 1 OR empire = 1", :order => DEFAULT_NEWS_ORDERING
  scope :not_error, :conditions => ["system_error = ?",false], :order => DEFAULT_NEWS_ORDERING
  # church
  scope :church, :conditions => {:church => true}, :limit => 100, :order => DEFAULT_NEWS_ORDERING
  # empire
  scope :empire, :conditions => {:empire => true}, :limit => 100, :order => DEFAULT_NEWS_ORDERING

  scope :home_news, lambda {|house|
    {:conditions => ["empire = 1 OR church = 1 OR noble_house_id = ?", house.id], :order => DEFAULT_NEWS_ORDERING, :limit => 100}
  }

  scope :empire_and_church, :conditions => ["empire = ? OR church = ?", true, true], :order => DEFAULT_NEWS_ORDERING, :limit => 100

  scope :oldest_first, :order => 'news_date ASC, id ASC'

  def source
    return nil if self.source_type.nil?
    k = Kernel.const_get(self.source_type)
    k.find_by_id(self.source_id)
  end
  def source=(c)
    if c.nil?
      self.source_type = nil
      self.source_id = 0
    else
      self.source_type = c.class.to_s
      self.source_id = c.id
    end
  end
  def target
    return nil if self.target_type.nil?
    if self.target_id.nil?
      return self.target_type
    else
      begin
        k = Kernel.const_get(self.target_type)
        k.find(self.target_id)
      rescue
        nil
      end
    end
  end
  def target=(c)
    if c.nil?
      self.target_type = nil
      self.target_id = 0
    elsif !c.class.respond_to?(:find)
      self.target_type = c
    else
      self.target_type = c.class.to_s
      self.target_id = c.id
    end
  end
  
  game_date :news_date
  validates_presence_of :code

  def self.add_news!(noble_house,source,code,target=nil, empire=false,church=false,news_date=Game.current_date,error_message=false)
    news = create!(:noble_house => noble_house, :code => code,
      :source => source, :target => target,
      :empire => empire, :church => church, :news_date => news_date,
      :system_error => error_message)
    news.noble_house.player.update_attributes!(:new_news_flag => true) unless news.noble_house.player.new_news_flag if news.noble_house && news.noble_house.player
    news
  end

  def source_name
    return '' unless self.source
    s = if self.source.class.name == 'Character'
      if self.target && ["ADD_TITLE","LOSE_TITLE","ADD_TITLE_MARRIAGE"].include?(self.code)
        self.source.name
      elsif self.target && self.target.class.name == 'Trait'
        self.source.name
      elsif self.target && self.target.class.name == 'Skill'
        self.source.name
      elsif self.code == 'BORN' || self.code == 'NOVICE' || self.code == 'ADULT' || self.code == 'CHARACTER_MOVE_ESTATE' || self.code == 'CHARACTER_HOME'
        self.source.name
      elsif self.code == 'MARRIED' || self.code == 'BETROTHED'
        self.source.name_and_family
      else
        self.source.display_name
      end
    elsif self.source.is_a?(NobleHouse)
      "House #{self.source.name}"
    else
      self.source.name
    end
    s
  end

  def target_name
    return '' unless self.target
    if self.target.is_a?(Character)
      if self.code == 'MARRIED' || self.code == 'BETROTHED'
        if self.target.noble_house == self.source.noble_house
          self.target.name
        else
          self.target.name_and_family
        end
      else
        self.target.display_name
      end
    elsif self.target.is_a?(Skill)
      "#{self.target.rank_name} in #{self.target.category}"
    elsif self.target.is_a?(Building)
      "#{self.target.building_type.category}"
    elsif self.target.is_a?(Estate)
      if self.code == 'CHARACTER_HOME'
        "Home Estate of #{self.target.name}"
      else
        "Estate #{self.target.name}"
      end
    elsif self.target.is_a?(NobleHouse)
      "House #{self.target.name}"
    elsif self.target.is_a?(World)
      "#{self.target.name} orbit"
    elsif self.target.respond_to?(:name)
      self.target.name
    elsif target.is_a?(Float)
      val = target.round(2)
      if val.round(0) == val.to_i
        val = val.to_i
      end
      val
    else
      self.target
    end
  end

  def set_description
    text = NewsLog::DESCRIPTIONS[self.code]
    unless text.blank?
      source_name = self.source_name || ''
      target_name = self.target_name || ''
      text = text.gsub('?HOUSE?',"House #{noble_house.name}")
      text = text.gsub("?SOURCE?",source_name.to_s)
      text = text.gsub("?TARGET?",target_name.to_s)
      self.description = text
    else
      self.description = "News code #{self.code} not found!"
    end
    self.target_type = nil if target_id.nil? # avoid long target texts in the varchar
  end
end
