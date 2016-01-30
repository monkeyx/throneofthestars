class Wedding < ActiveRecord::Base
  attr_accessible :estate, :groom, :bride, :event_date

  def self.load_list(data_file)
    list = []
    File.open(data_file, 'r') do |file|
      while line = file.gets do
        list << line
      end
    end
    list
  end

  WEDDING_GIFTS = load_list("#{File.dirname(__FILE__)}/../../config/wedding_gifts.csv")
  WEDDING_MISCHIEF = load_list("#{File.dirname(__FILE__)}/../../config/wedding_mischief.csv")
  WEDDING_FAUX_PAS = load_list("#{File.dirname(__FILE__)}/../../config/wedding_faux_pas.csv")
  
  belongs_to :estate
  belongs_to :groom, :class_name => 'Character'
  belongs_to :bride, :class_name => 'Character'
  game_date :event_date

  has_many :wedding_invites, :dependent => :destroy
  
  include ItemContainer
  include Events

  scope :of, lambda {|character|
    {:conditions => ["groom_id = ? OR bride_id = ?", character.id, character.id]}
  }

  scope :at, lambda {|estate|
    {:conditions => {:estate_id => estate.id}}
  }

  scope :now, :conditions => {:event_date => Game.current_date}

  def self.pending
    all.select{|event| event.pending? }
  end

  def self.pending_or_now
    all.select{|event| event.pending? || event.now? }
  end

  def self.pending_at(estate)
    at(estate).select{|event| event.pending? }
  end

  def self.host!(estate,bride,event_date,catering_and_gifts=[])
    transaction do
      wedding = create!(:estate => estate, :groom => bride.betrothed, :bride => bride, :event_date => event_date)
      news_target = "#{bride.display_name} and #{wedding.groom.display_name} on the #{event_date.to_pretty}"
      if wedding.groom.noble? || bride.noble?
        estate.add_empire_news!('HOST_WEDDING',news_target)
      else
        estate.add_news!('HOST_WEDDING',news_target)
      end
      character_news_target = "Estate #{estate.name} on the #{event_date.to_pretty}"
      bride.add_news!('BRIDE_WEDDING',character_news_target)
      wedding.groom.add_news!('GROOM_WEDDING',character_news_target)
      catering_and_gifts.each do |hash|
        item = hash[:item]
        quantity = hash[:quantity]
        qty_available = estate.count_item(item)
        quantity = qty_available if quantity > qty_available
        add_item!(item, quantity)
        estate.remove_item!(item, quantity)
      end
      wedding
    end
  end

  def guests_present
    @guests_present ||= Character.at(self.estate).guests(self)
  end

  def invited?(character)
    return false unless character
    return true if groom && character.id == groom_id
    return true if bride && character.id == bride.id
    self.wedding_invites.count(:conditions => {:character_id => character.id}) > 0
  end

  def invite!(character)
    return if invited?(character) || !pending?
    invite = self.wedding_invites.create!(:character => character, :sent_date => Game.current_date)
    character.add_news!("WEDDING_INVITE", "#{bride.display_name} and #{groom.display_name} on the #{event_date.to_pretty} at Estate #{estate.name}")
    invite
  end
  
  def guest_list
    self.wedding_invites.to_a.map{|invite| invite.character}
  end
  
  def guests_accepted
    self.wedding_invites.to_a.map{|invite| invite.character if invite.accepted? }
  end
  
  def guests_attended
    return [] if pending?
    self.wedding_invites.select{|invite| invite.attended?}.map{|invite| invite.character }
  end

  def happen!
    return unless now?
    lord = self.estate.lord
    attendance = 0
    self.wedding_invites.each do |invite|
      guest = invite.character
      if at_location?(guest)
        # showed up
        lord.add_honour!(1)
        guest.add_honour!(1)
        invite.attended!
        attendance += 1
      end
    end
    trade_goods_honour(attendance, Item::FOOD_GRAIN, 1, 0)
    trade_goods_honour(attendance, Item::FOOD_MEAT, 1, 0)
    trade_goods_honour(attendance, Item::DRINK_MEAD, 1, 0)
    trade_goods_honour(attendance, Item::DRINK_BEER, 1, 0)
    trade_goods_honour(attendance, Item::CLOTHING_FUR, 0, 1)
    trade_goods_honour(attendance, Item::CLOTHING_CLOTH, 0, 5)
    trade_goods_honour(attendance, Item::FOOD_FISH, 0, 1)
    trade_goods_honour(attendance, Item::DRINK_WINE, 0, 1)
    trade_goods_honour(attendance, Item::CLOTHING_SILK, 0, 10)
    send_report!
    estate.add_church_news!('WEDDING_HELD',"#{bride.display_name} and #{groom.display_name}")
    self.groom.marry!
  end

  def cancel!(reason=nil)
    return unless pending?
    transaction do
      self.items.each do |item|
        qty = count_item(item)
        remove_item!(item, qty)
        self.estate.add_item!(item,qty)
      end
      news_target = "#{bride.display_name} and #{groom.display_name}"
      news_target = news_target + " because #{reason}" if reason
      estate.add_church_news!('WEDDING_CANCELLED',news_target)
      destroy
    end
  end

  def send_report!
    houses = Character.at(estate).map{|c| c.noble_house }.select{|h| !h.ancient?}.uniq
    r = report
    houses.each do |house|
      Message.send_internal!(bride, "Wedding of #{bride.display_name} and #{groom.display_name}", 
        r, house.baron)
    end
    true
  end

  def report
    r = "[b]#{bride.name_and_family}[/b] and [b]#{groom.name_and_family}[/b] were married this chronum at Estate #{estate.name}"
    pastor = estate.deacon
    pastor = estate.region.bishop unless pastor
    pastor = estate.region.world.archbishop unless pastor
    r = r + " by #{pastor.display_name}" if pastor
    r = r + ".\n\n"
    r = r + "In attendance where the bride's parents [b]#{bride.father.display_name}[/b] and [b]#{bride.mother.display_name}[/b]"
    bride_family_resident = Character.at(estate).of_house(bride.noble_house).size
    if bride_family_resident > 0
      r = r + " and #{bride_family_resident} of House #{bride.noble_house.name}"
    end
    r = r + ".\n\n"
    groom_family_resident = Character.at(estate).of_house(groom.noble_house).size
    if groom_family_resident > 0
      r = r + "Also in attendance where #{groom_family_resident} members of House #{groom.noble_house.name} representing the groom.\n\n"
    else
      r = r + "Sadly, none of the groom's family could attend the festivities.\n\n"
    end
    worlds_attendance = {}
    nobles_attendance = []
    adults_attendance = []
    children_attendance = []
    male_courting_attendance = []
    female_courting_attendance = []
    Character.at(estate).each do |c|
      birth_world = c.birth_place.region.world if c.birth_place && c.birth_place.region
      nobles_attendance << c if c.noble?
      children_attendance << c if c.child?
      adults_attendance << c if c.adult?
      male_courting_attendance << c if c.single_male?
      female_courting_attendance << c if c.single_female?
      if birth_world
        count = worlds_attendance[birth_world]
        count = 0 unless count
        count += 1
        worlds_attendance[birth_world] = count
      end
    end
    if worlds_attendance.size > 0
      r = r + "Guests from "
      r = r + worlds_attendance.keys.sort{|a,b| worlds_attendance[b] <=> worlds_attendance[a]}.map{|world| "#{world.name} #{worlds_attendance[world]}"}.join(", ")
      r = r + " were in attendance.\n\n"
    end
    gift_giver = nobles_attendance.sample
    r = r + "#{gift_giver.display_name} presented the happy couple with #{random_gift}.\n" if gift_giver
    mischief_maker = children_attendance.sample
    r = r + "#{mischief_maker.display_name} nearly caused a minor diplomatic incident after #{mischief_event}.\n\n" if mischief_maker
    faux_pas = adults_attendance.sample
    r = r + "#{faux_pas.display_name} #{faux_pas_event}.\n\n" if faux_pas
    male_courting = male_courting_attendance.sample
    female_courting = female_courting_attendance.sample
    r = r + "#{male_courting.display_name} was spotted offering #{female_courting.display_name} a large bouquet of flowers.\n\n" if male_courting && female_courting
    r = r + "Finally, #{bride.name} and #{groom.name} would like to thank everyone for their attendance.\n\n"
    honeymoon = Region.all.sample
    r = r + "They will be honeymooning in #{honeymoon.name} on #{honeymoon.world.name}.\n\n"
    r
  end

  private
  def random_gift
    WEDDING_GIFTS.sample
  end

  def mischief_event
    WEDDING_MISCHIEF.sample
  end

  def faux_pas_event
    WEDDING_FAUX_PAS.sample
  end

  def trade_goods_honour(attendance, trade_good_type, min_required, bonus_given)
    return unless attendance > 0
    goods = sum_items(Item.trade_good(trade_good_type))
    total_required = (min_required * attendance)
    if total_required < goods
      self.estate.lord.lose_honour!(10 * (total_required - goods))
    end
    if total_required == 0 && goods >= 0
      goods = attendance if goods > attendance
      availability = (goods.to_f / attendance.to_f)
      bonus_given = (availability * bonus_given).round(0).to_i
      self.estate.noble_house.add_honour!((bonus_given * attendance))
      guests_attended.each{|c|c.add_honour!(bonus_given)}
    end
  end
end
