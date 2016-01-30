class DiplomaticRelation < ActiveRecord::Base
  attr_accessible :noble_house, :target, :cause, :proposed_by, :proposal_date, :response_by, :response_date, :category, :established_date, :accepted, :forced
  
  NONE = ''
  
  CASSUS_BELLI = "Cassus Belli"
  WAR = "War"
  TRUCE = "Truce"
  PEACE = "Peace"
  ALLY = "Ally"
  LIEGE = "Liege"
  VASSAL = "Vassal"

  RELATION_TYPES = [CASSUS_BELLI, WAR, TRUCE, PEACE, ALLY, LIEGE, VASSAL]

  INJUSTICE = "Injustice"
  TRIAL = "Lost Trial"
  IMPRISONMENT = "Imprisonment"
  ATTACK_HOUSE = "Attacked House"
  ATTACK_VASSAL = "Attacked Vassal"
  ATTACK_ALLY = "Attacked Ally"
  PIRACY = "Committed Piracy"
  IMPERIAL_ORDER = "Disobeyed Imperial Order"
  CHURCH_ORDER = "Disobeyed Church Order"
  ASSASSINATION = "Assasination"
  ESPIONAGE = "Espionage"
  BROKE_TRUCE = "Broke Truce"
  BROKE_OATH = "Broke Oath"
  TRUCE_EXPIRED = "Truce Expired"

  CASSUS_BELLI_TYPES = [NONE, INJUSTICE, TRIAL, IMPRISONMENT,
                        ATTACK_HOUSE, ATTACK_VASSAL, ATTACK_ALLY,
                        PIRACY, IMPERIAL_ORDER, CHURCH_ORDER,
                        ASSASSINATION, ESPIONAGE,
                        BROKE_TRUCE, BROKE_OATH, TRUCE_EXPIRED
  ]

  CAUSE_DESCRIPTION = {
    NONE => "of an unspecified matter",
    INJUSTICE => "of a matter of injustice", 
    TRIAL => "they lost a trial",
    IMPRISONMENT => "they wrongfully imprisoned a member of their house",
    ATTACK_HOUSE => "they attacked their house", 
    ATTACK_VASSAL => "they attacked their vassal", 
    ATTACK_ALLY => "they attacked their ally",
    PIRACY => "they commited acts of piracy", 
    IMPERIAL_ORDER => "they disobeyed an Imperial order", 
    CHURCH_ORDER => "they disobeyed an order from the Holy Pontiff",
    ASSASSINATION => "they assassinated a member of their house", 
    ESPIONAGE => "they commited an act of espionage at one of their estates",
    BROKE_TRUCE => "they broke a truce",
    BROKE_OATH => "broke their oath",
    TRUCE_EXPIRED => "their truce expired"
  }

  belongs_to :noble_house
  belongs_to :target, :class_name => 'NobleHouse'
  validates_inclusion_of :cause, :in => CASSUS_BELLI_TYPES, :if => Proc.new{|rel| !rel.cause.nil? }
  belongs_to :proposed_by, :class_name => 'Character'
  game_date :proposal_date
  belongs_to :response_by, :class_name => 'Character'
  game_date :response_date
  validates_inclusion_of :category, :in => RELATION_TYPES
  game_date :established_date
  # accepted
  # forced
  has_many :diplomatic_tokens, :dependent => :destroy

  scope :of, lambda {|noble_house|
    {:conditions => {:noble_house_id => noble_house.id}}
  }

  scope :with, lambda {|noble_house|
    {:conditions => {:target_id => noble_house.id}}
  }

  scope :category, lambda {|category|
    {:conditions => {:category => category}}
  }

  scope :offered, lambda {|noble_house|
    {:conditions => ['target_id = ? AND (accepted IS NULL OR accepted = 0)',noble_house.id]}
  }
  
  scope :accepted, :conditions => {:accepted => true}
  scope :pending, :conditions => ['accepted IS NULL OR accepted = 0']

  def self.current_relations(noble_house,target_house)
    return WAR if has_relations?(noble_house,target_house,WAR)
    return TRUCE if has_relations?(noble_house,target_house,TRUCE)
    return LIEGE if has_relations?(noble_house,target_house,LIEGE)
    return VASSAL if has_relations?(noble_house,target_house,VASSAL)
    return ALLY if has_relations?(noble_house,target_house,ALLY)
    return PEACE
  end

  def self.has_relations?(noble_house,target_house,category,cause=NONE)
    list = of(noble_house).with(target_house).category(category)
    return true if list.size < 1 && category == PEACE
    return false unless list.size > 0
    return list.first.accepted? unless category == CASSUS_BELLI
    list.each do |rel|
      return true if rel.cause == cause
    end
    false
  end

  def self.cassus_belli!(noble_house,target_house,cause)
    raise "No cause given" unless cause && cause != NONE
    remove_relation!(noble_house,target_house,CASSUS_BELLI)
    rel = add_relationship!(noble_house,target_house,nil,CASSUS_BELLI)
    rel.activate_relationship!(cause)
    noble_house.add_empire_news!("CASSUS_BELLI(#{cause})", target_house)
    rel
  end

  def self.create_relation!(noble_house,target_house,character,category,cause=NONE, tokens = [])
    return false if category != PEACE && has_relations?(noble_house,target_house,category,cause)
    return false unless noble_house && target_house && category
    transaction do
      case category
      when CASSUS_BELLI
        cassus_belli!(noble_house,target_house,cause)
      when WAR
        # may not be at war if vassal / liege
        # raise "Cannot go to war with vassal!" if has_relations?(noble_house,target_house,VASSAL)
        # raise "Cannot go to war with Liege!" if has_relations?(noble_house,target_house,LIEGE)
        # may not be at war and at peace
        remove_relation!(noble_house,target_house,PEACE)
        remove_relation!(target_house,noble_house,PEACE)
        # if you break a truce you give a cassus belli to everybody
        NobleHouse.active.each {|nh| cassus_belli!(nh,noble_house,BROKE_TRUCE)} if has_relations?(noble_house,target_house,TRUCE)
        # all allies of the target get a cassus belli
        target_house.allies.each {|nh| cassus_belli!(nh,noble_house,ATTACK_ALLY)}
        # the liege of the target get a cassus belli
        cassus_belli!(target_house.liege,noble_house,ATTACK_VASSAL) if target_house.liege
        # may not be at war and in truce
        remove_relation!(noble_house,target_house,TRUCE)
        remove_relation!(target_house,noble_house,TRUCE)
        # may not be at war and allies
        remove_relation!(noble_house,target_house,ALLY)
        remove_relation!(target_house,noble_house,ALLY)
        # if going to war lose all cassus bellis on target house
        remove_relation!(noble_house,target_house,CASSUS_BELLI)
        # finally add the war status
        add_relationship!(noble_house,target_house,character,WAR).activate_relationship!
        add_relationship!(target_house,noble_house,character,WAR).activate_relationship!
        noble_house.add_empire_news!("DECLARE_WAR",target_house)
        target_house.add_news!("DECLARED_WAR",noble_house)
      when LIEGE
        remove_relation!(noble_house,target_house,LIEGE) #remove previous offer
        # add liege offer
        add_relationship!(noble_house,target_house,character,LIEGE).add_tokens!(tokens)
        noble_house.add_news!("ALLEGIANCE_OFFER",target_house)
        target_house.add_news!("ALLEGIANCE_OFFERED",noble_house)
      when TRUCE
        remove_relation!(noble_house,target_house,TRUCE) #remove previous offer
        # add the truce offer
        add_relationship!(noble_house,target_house,character,TRUCE).add_tokens!(tokens)
        noble_house.add_news!("TRUCE_OFFER",target_house)
        target_house.add_news!("TRUCE_OFFERED",noble_house)
      when PEACE
        remove_relation!(noble_house,target_house,PEACE) #remove previous offer
        # add the peace offer
        add_relationship!(noble_house,target_house,character,PEACE).add_tokens!(tokens)
        noble_house.add_news!("PEACE_OFFER",target_house)
        target_house.add_news!("PEACE_OFFERED",noble_house)
      when ALLY
        remove_relation!(noble_house,target_house,ALLY) #remove previous offer
        # add the alliance offer
        add_relationship!(noble_house,target_house,character,ALLY).add_tokens!(tokens)
        noble_house.add_news!("ALLIANCE_OFFER",target_house)
        target_house.add_news!("ALLIANCE_OFFERED",noble_house)
      when VASSAL
        raise "Improper usage. Add liege to vassal's relations instead"
      end
    end
    nil
  end

  def self.remove_relation!(noble_house,target_house,category,add_news=true)
    transaction do
      of(noble_house).with(target_house).category(category).each do |rel| 
        rel.return_tokens! unless rel.accepted?
        if add_news && rel.accepted?
          if rel.alliance?
            noble_house.add_empire_news!("ALLIANCE_BREAK", target_house) 
            target_house.add_news!('ALLIANCE_BROKEN',noble_house)
          end
          if rel.liege?
            target_house.add_news!('ALLEGIANCE_CANCELLED',noble_house)
            noble_house.add_empire_news!("LIEGE_ALLEGIANCE_CANCELLED", target_house) 
          end
          if rel.vassal?
            target_house.add_news!('ALLEGIANCE_BROKE',noble_house)
            noble_house.add_empire_news!("VASSAL_ALLEGIANCE_BROKE", target_house) 
          end
        end
        rel.destroy
        remove_relation!(target_house,noble_house,category,false)
        noble_house.break_oath!(target_house) if category == LIEGE || category == VASSAL
      end
    end
  end

  def self.remove_all_relations!(noble_house,categories=RELATION_TYPES)
    transaction do
      categories.each do |category|
        of(noble_house).category(category).each do |rel| 
          remove_relation!(noble_house,rel.target_house,category)
        end
      end
    end
  end

  def self.remove_all_expired_truces!
    category(TRUCE).each do |truce| 
      if truce.expired?
        noble_house = truce.noble_house
        target = truce.target
        truce.destroy 
        create_relation!(noble_house,target,noble_house.baron,WAR,TRUCE_EXPIRED) unless noble_house.at_war?(target)
      end
    end
  end

  def tokens_string
    unless self.diplomatic_tokens.empty?
      "The offer includes: #{self.diplomatic_tokens.map{|token| token.to_s}.join(', ')}."
    end
  end

  def to_s
    if cassus_belli?
      "House #{noble_house.name} has a <span class='cassus_belli'>cassus belli</span> against House #{target.name} because #{CAUSE_DESCRIPTION[cause]}."
    elsif war?
      "House #{noble_house.name} is at <span class='war'>war</span> with House #{target.name}."
    elsif truce?
      if accepted?
        "House #{noble_house.name} has a <span class='truce'>truce</span> with House #{target.name} until #{(self.established_date + 10).pp}."
      else
        "House #{noble_house.name} has <span class='truce'>offered a truce</span> to House #{target.name}. #{tokens_string}"
      end
    elsif alliance?
      if accepted?
        "House #{noble_house.name} and House #{target.name} are <span class='alliance'>allied</span>."
      else
        "House #{noble_house.name} has offered an <span class='alliance'>alliance</span> to House #{target.name}. #{tokens_string}"
      end
    elsif liege?
      if accepted?
        "House #{noble_house.name} is the <span class='vassal'>vassal</span> of House #{target.name}."
      else
        "House #{noble_house.name} has offered their <span class='vassal'>allegiance</span> to House #{target.name}. #{tokens_string}"
      end
    elsif vassal?
      "House #{noble_house.name} is the <span class='liege'>liege</span> of House #{target.name}."
    elsif peace?
      unless accepted?
        "House #{noble_house.name} has <span class='peace'>offered peace</span> to House #{target.name}. #{tokens_string}"
      else
        '' # don't show peace
      end
    end
  end

  def war?
    self.category == WAR
  end

  def truce?
    self.category == TRUCE
  end

  def alliance?
    self.category == ALLY
  end

  alias_method :ally?, :alliance?

  def peace?
    self.category == PEACE
  end

  def oath?
    liege? || vassal?
  end

  def liege?
    self.category == LIEGE
  end

  def vassal?
    self.category == VASSAL
  end

  def cassus_belli?
    self.category == CASSUS_BELLI
  end

  def expired?
    truce? && accepted? && established_date && Game.current_date.difference(established_date) >= 10
  end

  def offer_truce!(character,tokens=[])
    raise "Not a war" unless war?
    DiplomaticRelation.create_relation!(noble_house,target,character,TRUCE,nil,tokens)
  end

  def offer_peace!(character,tokens=[])
    raise "Not a war" unless war?
    DiplomaticRelation.create_relation!(noble_house,target,character,PEACE,nil,tokens)
  end

  def declare_war!(character)
    raise "Not a cassus belli" unless cassus_belli?
    DiplomaticRelation.create_relation!(noble_house,target,character,WAR,cause)
  end

  def accept!(character,lands_to_estate=nil)
    transaction do
      update_attributes!(:accepted => true, :response_by => character, :response_date => Game.current_date, :established_date => Game.current_date)
      case self.category
      when TRUCE
        # may not be at war and in truce
        DiplomaticRelation.remove_relation!(noble_house,target,WAR)
        # may not be in truce and at peace
        DiplomaticRelation.remove_relation!(noble_house,target,PEACE,false)
        # return the truce
        self.activate_relationship!
        rel = DiplomaticRelation.add_relationship!(target,noble_house,character,TRUCE)
        rel.activate_relationship!
        self.target.add_empire_news!("TRUCE_ACCEPTED", self.noble_house)
        self.noble_house.add_news!("TRUCE_OFFER_ACCEPTED", self.target)
      when PEACE
        # may not be at war and at peace
        DiplomaticRelation.remove_relation!(noble_house,target,WAR)
        # may not be in truce and at peace
        DiplomaticRelation.remove_relation!(noble_house,target,TRUCE,false)
        # if going to peace lose all cassus bellis
        DiplomaticRelation.remove_relation!(noble_house,target,CASSUS_BELLI,false)
        # return the peace
        self.activate_relationship!
        rel = DiplomaticRelation.add_relationship!(target,noble_house,character,PEACE)
        rel.activate_relationship!
        self.target.add_empire_news!("PEACE_ACCEPTED", self.noble_house)
        self.noble_house.add_news!("PEACE_OFFER_ACCEPTED", self.target)
      when ALLY
        # may not be at war and allies
        DiplomaticRelation.remove_relation!(noble_house,target,WAR)
        # no need for peace
        DiplomaticRelation.remove_relation!(noble_house,target,PEACE,false)
        # if going to be allies lose all cassus bellis
        DiplomaticRelation.remove_relation!(noble_house,target,CASSUS_BELLI,false)
        # form the alliance
        self.activate_relationship!
        rel = DiplomaticRelation.add_relationship!(target,noble_house,character,ALLY)
        rel.activate_relationship!
        self.target.add_empire_news!("ALLIANCE_ACCEPTED", self.noble_house)
        self.noble_house.add_news!("ALLIANCE_OFFER_ACCEPTED", self.target)
      when LIEGE
        # no more than one liege
        noble_house.break_oath! unless noble_house.liege && noble_house.liege.id == target.id
        # may not be at war any longer
        DiplomaticRelation.remove_relation!(noble_house,target,WAR)
        # no need for a truce
        DiplomaticRelation.remove_relation!(noble_house,target,TRUCE,false)
        # no need for alliance
        DiplomaticRelation.remove_relation!(noble_house,target,ALLY,false)
        # peace can go too
        DiplomaticRelation.remove_relation!(noble_house,target,PEACE,false)
        # if going to be vassal lose all cassus bellis
        DiplomaticRelation.remove_relation!(noble_house,target,CASSUS_BELLI,false)
        # form the oath
        self.activate_relationship!
        rel = DiplomaticRelation.add_relationship!(target,noble_house,character,VASSAL)
        rel.activate_relationship!
        self.target.add_empire_news!("ALLEGIANCE_ACCEPTED", self.noble_house)
        self.noble_house.add_news!("ALLEGIANCE_OFFER_ACCEPTED", self.target)
      end
      accept_tokens!(lands_to_estate)
    end
  end

  def reject!(character)
    transaction do
      return_tokens!
      case self.category
      when TRUCE
        self.target.add_news!("TRUCE_REJECTED", self.noble_house)
        self.noble_house.add_news!("TRUCE_OFFER_REJECTED", self.target)
      when PEACE
        self.target.add_news!("PEACE_REJECTED", self.noble_house)
        self.noble_house.add_news!("PEACE_OFFER_REJECTED", self.target)
      when ALLY
        self.target.add_news!("ALLIANCE_REJECTED", self.noble_house)
        self.noble_house.add_news!("ALLIANCE_OFFER_REJECTED", self.target)
      when LIEGE
        self.target.add_news!("ALLEGIANCE_REJECTED", self.noble_house)
        self.noble_house.add_news!("ALLEGIANCE_OFFER_REJECTED", self.target)
      end
      destroy
    end
  end

  def self.add_relationship!(noble_house,target_house,character,category)
    create!(:noble_house => noble_house, :target => target_house, :proposed_by => character, :proposal_date => Game.current_date, :category => category)
  end

  def activate_relationship!(cause=nil)
    update_attributes!(:accepted => true, :established_date => Game.current_date, :cause => cause)
  end

  def accept_tokens!(lands_to_estate=nil)
    self.diplomatic_tokens.each do |token|
      if token.estate
        if token.lands
          if lands_to_estate && lands_to_estate.region_id == token.estate.region_id
            lands_to_estate.add_lands!(token.lands)
          else
            region = token.estate.region
            name = "New #{region.name.pluralize}"
            estate = Estate.build!(target,region,name)
            estate.add_lands!(token.lands)
            target.baron.add_title!(Title::LORD,estate)
          end
        elsif token.estate.noble_house_id == noble_house.id
          estate.update_attributes!(:noble_house => target)
        end
      end
      if token.oath?
        DiplomaticRelation.create_relation!(noble_house,target,noble_house.baron,LIEGE)
      end
      token.destroy
    end
  end

  def add_tokens!(tokens)
    tokens.each do |token|
      if token.valid_for?(self)
        token.diplomatic_relation = self
        token.save!
        noble_house.subtract_wealth!(token.sovereigns) if token.sovereigns > 0
        token.estate.subtract_lands!(token.lands) if token.estate && token.lands > 0
      end
    end
  end

  def return_tokens!
    self.diplomatic_tokens.each do |token|
      noble_house.add_wealth!(token.sovereigns) if token.sovereigns > 0
      token.estate.add_lands!(token.lands) if token.estate && token.lands > 0
      token.destroy
    end
  end
end
