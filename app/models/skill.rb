class Skill < ActiveRecord::Base
  attr_accessible :character, :character_id, :category, :obtained_date, :training, :training_start_date, :rank, :training_points
  
  NONE = 0
  NEOPHYTE = 1
  APPRENTICE = 2
  EXPERT = 3
  MASTER = 4

  RANK_NONE = "Student"
  RANK_NEOPHYTE = "Neophyte"
  RANK_APPRENTICE = "Apprentice"
  RANK_EXPERT = "Expert"
  RANK_MASTER = "Master"

  RANK_NAMES = {NONE => RANK_NONE, NEOPHYTE => RANK_NEOPHYTE, APPRENTICE => RANK_APPRENTICE, EXPERT => RANK_EXPERT, MASTER => RANK_MASTER}

  SKILL_RANKS = [NONE,NEOPHYTE,APPRENTICE,EXPERT,MASTER]
  
  CIVIL_ADMINISTRATION = "Administration"
  CIVIL_MANAGEMENT = "Management"
  CIVIL_ENGINEERING = "Engineering"
  CIVIL_RECRUITMENT = "Recruitment"
  CIVIL_ETIQUETTE = "Etiquette"
  CIVIL_BARTER = "Barter"
  CIVIL_ORGANIZATION = "Organization"
  MILITARY_LEADERSHIP = "Leadership"
  MILITARY_TACTICS = "Tactics"
  MILITARY_FORTIFICATIONS = "Fortification"
  MILITARY_RECON = "Reconnaissance"
  MILITARY_MELEE = "Melee"
  MILITARY_EXPLOSIVES = "Explosives"
  MILITARY_LOGISTICS = "Logistics"
  NAVAL_NAVIGATION = "Navigation"
  NAVAL_PILOTING = "Piloting"
  NAVAL_SHOOTING = "Shooting"
  NAVAL_REPAIR = "Repair"
  NAVAL_ELECTRONICS = "Electronics"
  NAVAL_DAMAGE_CONTROL = "Damage Control"
  NAVAL_SHIPWRIGHT = "Shipwright"
  CHURCH_THEOLOGY = "Theology"
  CHURCH_DIPLOMACY = "Diplomacy"
  CHURCH_RESEARCH = "Research"
  CHURCH_APOTHECARY = "Apothecary"
  CHURCH_MEDICINE = "Medicine"
  CHURCH_BIOGENICS = "Biogenics"
  CHURCH_AUTOMATION = "Automation"
  
  CIVIL_SKILLS = [CIVIL_ADMINISTRATION,CIVIL_MANAGEMENT,CIVIL_ENGINEERING,CIVIL_RECRUITMENT,CIVIL_ETIQUETTE,CIVIL_BARTER,CIVIL_ORGANIZATION]
  MILITARY_SKILLS = [MILITARY_LEADERSHIP,MILITARY_TACTICS,MILITARY_FORTIFICATIONS,MILITARY_RECON,MILITARY_MELEE,MILITARY_EXPLOSIVES,MILITARY_LOGISTICS]
  NAVAL_SKILLS = [NAVAL_NAVIGATION,NAVAL_PILOTING,NAVAL_SHOOTING,NAVAL_REPAIR,NAVAL_ELECTRONICS,NAVAL_DAMAGE_CONTROL,NAVAL_SHIPWRIGHT]
  CHURCH_SKILLS = [CHURCH_THEOLOGY,CHURCH_DIPLOMACY,CHURCH_RESEARCH,CHURCH_APOTHECARY,CHURCH_MEDICINE,CHURCH_BIOGENICS,CHURCH_AUTOMATION]

  SKILL_TYPES = CIVIL_SKILLS + MILITARY_SKILLS + NAVAL_SKILLS + CHURCH_SKILLS

  CIVIL_TYPE = "Civil"
  MILITARY_TYPE = "Military"
  NAVAL_TYPE = "Naval"
  CHURCH_TYPE = "Ecclesiastical"

  USEFUL_CHANCELLOR_SKILLS = [CIVIL_ADMINISTRATION]
  USEFUL_STEWARD_SKILLS = [CIVIL_MANAGEMENT,CIVIL_ENGINEERING,CIVIL_ETIQUETTE,CIVIL_ORGANIZATION,CHURCH_BIOGENICS,CHURCH_AUTOMATION]
  USEFUL_TRIBUNE_SKILLS = [CIVIL_RECRUITMENT]
  USEFUL_CREW_SKILLS = [NAVAL_NAVIGATION,NAVAL_PILOTING,NAVAL_SHOOTING,NAVAL_REPAIR,NAVAL_ELECTRONICS,NAVAL_DAMAGE_CONTROL,CHURCH_MEDICINE]
  USEFUL_ARMY_SKILLS = [MILITARY_LEADERSHIP,MILITARY_TACTICS,MILITARY_FORTIFICATIONS,MILITARY_RECON,MILITARY_MELEE,MILITARY_EXPLOSIVES,MILITARY_LOGISTICS,CHURCH_MEDICINE]
  USEFUL_EMISSARY_SKILLS = [CHURCH_DIPLOMACY, CHURCH_RESEARCH, CHURCH_APOTHECARY]

  belongs_to :character
  validates_inclusion_of :category, :in => SKILL_TYPES
  game_date :obtained_date
  # training
  scope :training, :conditions => {:training => true}
  scope :not_training, :conditions => {:training => false, :training_points => 0}
  
  game_date :training_start_date
  validates_inclusion_of :rank, :in => SKILL_RANKS

  scope :of, lambda {|character|
    {:conditions => {:character_id => character.id}}
  }

  scope :category, lambda {|category|
    {:conditions => {:category=> category}}
  }

  scope :categories, lambda {|categories|
    {:conditions => ["category IN (?)", categories]}
  }

  scope :rank, lambda {|r|
    {:conditions => {:rank => r}}
  }

  def self.best_skill(characters,skill)
    best = 0
    characters.each do |c|
      unless c.nil?
        rank = c.skill_rank(skill)
        best = rank if rank && rank > best
      end
    end
    best
  end

  def self.add_skill!(character,category,rank=NEOPHYTE,training_points=0)
    skill = find(:first,:conditions => {:character_id => character.id, :category => category})
    skill = create!(:character => character, :category => category, :obtained_date => Game.current_date, :training_points => 0) unless skill
    skill.rank = rank
    skill.training_points = skill.training_points + training_points
    skill.save!
    skill
  end

  def self.skill_rank(character,category)
    return 0 unless character && category
    skill = find(:first,:conditions => {:character_id => character.id, :category => category})
    skill ? skill.rank : NONE
  end

  def self.skill_rank_name(character,category)
    skill = find(:first,:conditions => {:character_id => character.id, :category => category})
    skill ? skill.rank_name : RANK_NONE
  end

  def self.train_skill!(character,category)
    return false unless category && SKILL_TYPES.include?(category) && character && character.can_train_skill?(category)
    skill = find(:first,:conditions => {:character_id => character.id, :category => category})
    skill = create!(:character_id => character.id, :category => category, :rank => 0) unless skill
    skill.train!
    true
  end

  def self.clear_student_ranks!
    rank(NONE).not_training.destroy_all
  end

  def self.currently_training_skill(character)
    of(character).training.first
  end

  def training_complete_percentage
    ((self.training_points.to_f / training_points_required.to_f) * 100.0).round(0).to_i
  end

  def next_rank
    r = self.rank + 1
    r > MASTER ? MASTER : r
  end

  def next_rank_name
    rank_name(next_rank)
  end

  def training_progress
    return nil unless training_points > 0
    "#{training_complete_percentage}% to #{next_rank_name}"
  end

  def train!
    return false if training?
    self.character.skills.each {|skill| skill.stop_training!}
    update_attributes!(:training => true, :training_start_date => Game.current_date)
    true
  end

  def stop_training!
    return false unless training?
    update_attributes!(:training => false, :training_start_date => nil)
    true
  end

  def check_training!
    return false unless training?
    return stop_training! if self.rank == MASTER
    update_attributes!(:training_points => (self.training_points + 1))
    return false unless training_points_required <= self.training_points
    r = self.rank + 1
    t = !(r == MASTER)
    d = t ? Game.current_date : nil
    update_attributes!(:training => t, :rank => r, :training_start_date => d, :training_points => 0)
    self.character.add_news!("ADD_SKILL",to_s)
    true
  end

  def training_points_required
    case self.category_type
    when CIVIL_TYPE
      return case rank
      when NONE
        10
      when NEOPHYTE
        30
      when APPRENTICE
        60
      when EXPERT
        100
      end
    when MILITARY_TYPE
      return case rank
      when NONE
        10
      when NEOPHYTE
        10
      when APPRENTICE
        30
      when EXPERT
        50
      end
    when NAVAL_TYPE
      return case rank
      when NONE
        10
      when NEOPHYTE
        10
      when APPRENTICE
        30
      when EXPERT
        50
      end
    when CHURCH_TYPE
      return case rank
      when NONE
        20
      when NEOPHYTE
        60
      when APPRENTICE
        70
      when EXPERT
        130
      end
    end
    0
  end

  def category_type
    return CIVIL_TYPE if civil?
    return MILITARY_TYPE if military?
    return NAVAL_TYPE if naval?
    return CHURCH_TYPE if church?
  end

  def civil?
    CIVIL_SKILLS.include?(self.category)
  end
  def military?
    MILITARY_SKILLS.include?(self.category)
  end
  def naval?
    NAVAL_SKILLS.include?(self.category)
  end
  def church?
    CHURCH_SKILLS.include?(self.category)
  end

  def swords?
    self.category == MILITARY_MELEE
  end

  def lances?
    self.category == CIVIL_ETIQUETTE
  end

  def rank_name(r=self.rank)
    RANK_NAMES[r]
  end

  def >(skill)
    return true if skill.nil?
    return true unless self.category == skill.category
    self.rannk > skill.category
  end

  def <(skill)
    return false if skill.nil?
    return false unless self.category == skill.category
    self.rank < skill.category
  end

  def ==(skill)
    return false if skill.nil?
    return false unless self.category == skill.category
    self.rank == skill.category
  end

  def tax_modifier
    (self.category == CIVIL_ADMINISTRATION ? 0.1 : 0) * self.rank
  end

  def efficiency_modifier
    (self.category == CIVIL_MANAGEMENT ? 0.1 : 0) * self.rank
  end

  def building_cost_modifier
    (self.category == CIVIL_ENGINEERING ? -0.1 : 0) * self.rank
  end

  def recruitment_modifier
    (self.category == CIVIL_RECRUITMENT ? 0.1 : 0) * self.rank
  end

  def event_reward_modifier
    (self.category == CIVIL_ETIQUETTE ? 0.25 : 0) * self.rank
  end

  def lance_combat
    (self.category == CIVIL_ETIQUETTE ? 1 : 0) * self.rank
  end

  def land_purchase_modifier
    (self.category == CIVIL_BARTER ? -0.1 : 0) * self.rank
  end

  def project_cost_modifier
    (self.category == CIVIL_BARTER ? -0.1 : 0) * self.rank
  end

  def workers_needed
    (self.category == CIVIL_ORGANIZATION ? -0.1 : 0) * self.rank
  end

  def morale_modifier
    (self.category == MILITARY_LEADERSHIP ? 0.1 : 0) * self.rank
  end

  def tactics_combat
    (self.category == MILITARY_TACTICS ? 1 : 0) * self.rank
  end

  def ground_armour_save
    (self.category == MILITARY_FORTIFICATIONS ? 1 : 0) * self.rank
  end

  def strategic_combat
    (self.category == MILITARY_RECON ? 1 : 0) * self.rank
  end

  def board_combat
    (self.category == MILITARY_MELEE ? 1 : 0) * self.rank
  end

  def sword_combat
    (self.category == MILITARY_MELEE ? 1 : 0) * self.rank
  end

  def enemy_fort_save
    (self.category == MILITARY_EXPLOSIVES ? -1 : 0) * self.rank
  end

  def sabotage
    (self.category == MILITARY_EXPLOSIVES ? 1 : 0) * self.rank
  end

  def army_move_cost
    (self.category == MILITARY_LOGISTICS ? -2 : 0) * self.rank
  end

  def ship_move_cost_modifier
    (self.category == NAVAL_NAVIGATION ? -0.1 : 0) * self.rank
  end

  def space_dodge_save
    (self.category == NAVAL_PILOTING ? 1 : 0) * self.rank
  end

  def space_shoot
    (self.category == NAVAL_SHOOTING ? 1 : 0) * self.rank
  end

  def pistol_combat
    (self.category == NAVAL_SHOOTING ? 1 : 0) * self.rank
  end

  def hull_point_repair
    (self.category == NAVAL_REPAIR ? 10 : 0) * self.rank
  end

  def energy_save
    (self.category == NAVAL_ELECTRONICS ? 1 : 0) * self.rank
  end

  def sensors
    (self.category == NAVAL_ELECTRONICS ? 1 : 0) * self.rank
  end

  def internal_damage
    (self.category == NAVAL_DAMAGE_CONTROL ? -2 : 0) * self.rank
  end

  def hull_assembled
    (self.category == NAVAL_SHIPWRIGHT ? 5 : 0) * self.rank
  end

  def tithe_modifier
    (self.category == CHURCH_THEOLOGY ? 0.1 : 0) * self.rank
  end

  def influence
    (self.category == CHURCH_DIPLOMACY ? 1 : 0) * self.rank
  end

  def research
    (self.category == CHURCH_RESEARCH ? 1 : 0) * self.rank
  end

  def assassination
    (self.category == CHURCH_APOTHECARY ? 1 : 0) * self.rank
  end

  def injury_modifier
    (self.category == CHURCH_MEDICINE ? -1 : 0) * self.rank
  end

  def trade_good_modifier
    (self.category == CHURCH_BIOGENICS ? 0.1 : 0) * self.rank
  end

  def ore_modifier
    (self.category == CHURCH_AUTOMATION ? 0.1 : 0) * self.rank
  end

  def to_s
    s = "#{self.category} #{rank_name}"
    s = s + " (#{training_progress})" if self.training_points > 0
    s
  end
end
