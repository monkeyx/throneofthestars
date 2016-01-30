class Law < ActiveRecord::Base
  attr_accessible :category, :enacted_date, :enacted_by, :revoked_date, :revoked_by, :refused_by
  
  LAW_CIVILITY = "Law of Civility"
  LAW_PROPERTY = "Law of Property"
  LAW_FEALTY = "Law of Fealty"
  LAW_HABEAS_CORPUS = "Law of Habeas Corpus"
  LAW_BUREAUCRACY = "Law of Bureaucracy"
  LAW_BANISHMENT = "Law of Banishment"
  LAW_IMPERIAL_AUTHORITY = "Law of Imperial Authority"

  LAWS = [LAW_CIVILITY,  LAW_PROPERTY,  LAW_FEALTY,  LAW_HABEAS_CORPUS,  LAW_BUREAUCRACY,  LAW_BANISHMENT,  LAW_IMPERIAL_AUTHORITY]

  EDICT_ABSOLUTION = "Edict of Absolution"
  EDICT_EMANCIPATION = "Edict of Emancipation"
  EDICT_CHASTITY = "Edict of Chastity"
  EDICT_FORGIVENESS = "Edict of Forgiveness"
  EDICT_INSPIRATION = "Edict of Inspiration"
  EDICT_HERESY = "Edict of Heresy"
  EDICT_CHURCH_AUTHORITY = "Edict of Church Authority"

  EDICTS = [EDICT_ABSOLUTION,  EDICT_EMANCIPATION,  EDICT_CHASTITY,  EDICT_FORGIVENESS,  EDICT_INSPIRATION,  EDICT_HERESY,  EDICT_CHURCH_AUTHORITY]

  LAWS_AND_EDICTS = LAWS + EDICTS

  validates_inclusion_of :category, :in => LAWS_AND_EDICTS
  game_date :enacted_date
  belongs_to :enacted_by, :class_name => 'Character'
  game_date :revoked_date
  belongs_to :revoked_by, :class_name => 'Character'
  belongs_to :refused_by, :class_name => 'Character'
  def target
    k = Kernel.const_get(self.target_type)
    k.find(target_id)
  end
  def target=(o)
    self.target_type = o.class.to_s
    self.target_id = o.id
  end
  # active

  scope :against, lambda {|target|
    {:conditions => {:target_type => target.class.to_s, :target_id => target.id}}
  }

  scope :by, lambda {|character|
    {:conditions => {:character_id => character.id}}
  }

  scope :category, lambda {|category|
    {:conditions => {:category => category}}
  }

  scope :active, :conditions => {:active => true}

  scope :imperial_laws, :conditions => ["category IN (?) AND active = ?",LAWS,true]
  scope :church_edicts, :conditions => ["category IN (?) AND active = ?",EDICTS,true]

  def self.is_active?(law_or_edict)
    category(law_or_edict).active.size > 0
  end

  def self.piracy_outlaws?
    is_active?(LAW_PROPERTY)
  end

  def self.court_trials?
    is_active?(LAW_HABEAS_CORPUS)
  end

  def self.world_projects_cost_modifier
    is_active?(LAW_BUREAUCRACY) ? -0.25 : 0
  end

  def self.emancipation?
    is_active?(EDICT_EMANCIPATION)
  end

  def self.clergy_may_marry?
    !is_active?(EDICT_CHASTITY)
  end

  def self.church_trials?
    is_active?(EDICT_FORGIVENESS)
  end

  def self.faith_projects_cost_modifier
    is_active?(EDICT_INSPIRATION) ? -0.25 : 0
  end

  def self.pass_law!(character,law,category)
    return unless character && Character.emperor && character.id == Character.emperor.id
    return unless target || !is_active?(category)
    # TODO law funding
    law = create!(:category => category, :enacted_date => Game.current_date,:enacted_by => character)
    if target
      law.target = target
      target.exile! if category == LAW_BANISHMENT
    else
      law.active = true
    end
    law.save!
  end

  def self.issue_edict!(character,category,target=nil)
    return unless character && Character.pontiff && character.id == Character.pontiff.id
    return unless target || !is_active?(category)
    edict = create!(:category => category, :enacted_date => Game.current_date,:enacted_by => character)
    if target
      edict.target = target
      target.heretic! if category == EDICT_HERESY
    else
      edict.active = true
    end
    edict.save!
  end

  def law?
    LAWS.include?(self.category)
  end

  def edict?
    EDICTS.include?(self.category)
  end

  def accept!
    # TODO swear fealty
    # TODO negotiate truce
    # TODO free slaves
    # TODO estate confiscation
  end

  def reject!
    if law?
      target_house = self.target.is_a?(NobleHouse) ? self.target : self.target.noble_house
      NobleHouse.active.each {|noble_house| DiplomaticRelation.cassus_belli!(noble_house, target_house, DiplomaticRelation::IMPERIAL_ORDER)}
      destroy
    else
      target_house = self.target.is_a?(NobleHouse) ? self.target : self.target.noble_house
      target_house.lose_piety!(target_house.piety * 0.25)
    end
  end
end
