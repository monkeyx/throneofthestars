module CharactersHelper
  def link_to_character(character,name_method=:display_name)
    return if character.nil?
    name = character.send(name_method)
    link_to "#{name}", character_path(character)
  end

  def pronoun(character)
    character.male? ? "He" : "She"
  end

  def is_or_was(character)
    character.dead? ? "was" : "is"
  end

  def relationship_description(character)
    if character.spouse
      return "Widowed" if character.spouse.dead?
      return "Married"
    elsif character.betrothed
      return "Betrothed"
    elsif character.infant?
      return "Infant"
    elsif character.child?
      return "Child"
    else
      return "Single"
    end
  end

  def health_description(character)
    return nil if character.nil? || character.dead? || character.health == 0
    return "perfect" if character.health == 100
    return "very good" if character.health > 90
    return "good" if character.health > 70
    return "poor" if character.health > 50
    return "ill" if character.health > 25
    return "dire"
  end

  def loyalty_description(character)
    return nil if character.nil? || character.dead? || character.health == 0
    return "Steadfast" if character.loyalty > 90
    return "Loyal" if character.loyalty > 70
    return "Doubting" if character.loyalty > 50
    return "Unhappy" if character.loyalty > 25
    return "Disloyal Scum"
  end

  def intimidation_description(character)
    return nil if character.nil? || character.dead? || character.health == 0 || character.intimidation == 0
    return "Fearsome" if character.intimidation > 2
    return "Formidable" if character.intimidation > 0
    return "Puny" if character.intimidation < -2
    return "Wimpy" if character.intimidation < 0
    nil
  end

  def influence_description(character)
    return nil if character.nil? || character.dead? || character.health == 0 || character.influence == 0
    return "Silver-Tongued" if character.influence > 2
    return "Persuasive" if character.influence > 0
    return "Brutish" if character.influence < -2
    return "Tongue-tied" if character.influence < 0
    nil
  end

  def glory_description(character)
    return nil if character.nil? || character.dead? || character.health == 0 || character.glory_modifier == 0
    return "Heroic" if character.glory_modifier > 0.25
    return "Brave" if character.glory_modifier > 0
    return "Cautious" if character.glory_modifier < -0.25
    return "Squeemish" if character.glory_modifier < 0
    nil
  end

  def piety_description(character)
    return nil if character.nil? || character.dead? || character.health == 0 || character.piety_modifier == 0
    return "Pious" if character.piety_modifier > 0.25
    return "Religious" if character.piety_modifier > 0
    return "Blasphemous" if character.piety_modifier < -0.25
    return "Worldly" if character.piety_modifier < 0
    nil
  end

  def honour_description(character)
    return nil if character.nil? || character.dead? || character.health == 0 || character.honour_modifier == 0
    return "Honourable" if character.honour_modifier > 0.25
    return "Upright" if character.honour_modifier > 0
    return "Dishonourable" if character.honour_modifier < -0.25
    return "Fickle" if character.honour_modifier < 0
    nil
  end

  def options_for_characters_list(selected,list)
    list = [] if list.empty?
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","display_name",id)
  end

  def options_for_characters(selected,house)
    options_for_characters_list(selected, house.nil? ? [] : Character.of_house(house).living)
  end

  def options_for_barons(selected)
    options_for_characters_list(selected, Character.player_barons(current_baron))
  end

  def options_for_brides(selected,house)
    options_for_characters_list(selected, house.nil? ? [] : Character.of_house(house).female.betrothed)
  end

  def options_for_characters_at_location(selected,location,exclude_character)
    options_for_characters_list(selected, location.nil? ? [] : Character.at(location).exclude(exclude_character))
  end

  def options_for_prisoners_estate(selected,estate)
    options_for_characters_list(selected, estate.nil? ? [] : Character.at(estate).prisoner)
  end

  def options_for_prisoners_house(selected,noble_house)
    options_for_characters_list(selected, noble_house.nil? ? [] : Character.of_house(noble_house).prisoner)
  end

  def character_lineage(character)
    return nil unless character.father
    s = character.male? ? "#{pronoun(character)} #{is_or_was(character)} a son of " : "#{pronoun(character)} #{is_or_was(character)} a daughter of "
    s = s + link_to_character(character.father)
    s = s + " and " + link_to_character(character.mother) if character.mother
    s
  end

  def character_relations(character)
    if character.betrothed
      return "Beloved of #{link_to_character(character.betrothed)}"
    elsif character.spouse
      s = character.male? ? "Husband of " : "Wife of "
      s = s + link_to_character(character.spouse)
      return s
    end
    nil
  end

  def character_rightful_heir(character)
    unless character.dead?
      heir = character.rightful_heir
      unless heir.nil?
        return "#{pronoun(character)} will be succeeded by #{link_to_character(heir)}".html_safe
      end
    end
    nil
  end

  def character_description(character)
    list = []
    unless character.noble_house.nil?
      house_status = character.major? ? "major" : "minor"
      list << "#{pronoun(character)} #{is_or_was(character)} a #{house_status} member of #{link_to_house(character.noble_house)}"
    else
      list << "#{pronoun(character)} #{is_or_was(character)} of no house"
    end
    lineage = character_lineage(character)
    list << lineage unless lineage.blank?
    relation = character_relations(character)
    list << relation unless relation.blank?
    heir = character_rightful_heir(character)
    list << heir unless heir.blank?
    (list.join(". ") + ".").html_safe
  end

  def character_birth(character)
    list = []
    list << "on the #{character.birth_date.to_pretty}" if character.birth_date
    list << "at #{link_to_estate(character.birth_place)}" if character.birth_place
    s = "#{pronoun(character)} was born " + list.join(" ") + ","
    s = s + " #{pronoun(character)} is #{character.age} years old." if character.alive?
    s.html_safe
  end

  def character_status(character)
    list = []
    if character.dead?
      list << "#{pronoun(character)} <strong>died on #{character.death_date.to_pretty}</strong>"
    else
      list << "#{pronoun(character)} is in <strong>#{health_description(character)} health</strong>"
      unless character.noble_house.nil? || !belongs_to_current_player?(character)
        list << "with <strong>#{character.action_points} out of 10 Action Points</strong>" if character.adult?
      end
    end
    (list.join(" ") + ".").html_safe
  end

  def character_liege(character)
    if character.liege.nil?
      "#{character.display_name} is an independent noble.".html_safe
    else
      "#{character.display_name} is the vassal of #{link_to_character(character.liege)}".html_safe
    end
  end

  def character_tournaments(character)
    return nil unless character.tournaments.size > 0
    list = character.tournaments.map{|tournament| "Estate #{tournament.estate.name} on #{tournament.event_date.to_pretty}"}
    ("#{pronoun(character)} is due to fight in tournaments at the following estates: " + (list.join(", ")) + ".").html_safe
  end

  def character_wedding(character)
    return nil unless character.wedding
    return nil if character.wedding.now? || character.wedding.past?
    "#{pronoun(character)} will be married on the #{character.wedding.event_date.to_pretty} at Estate #{character.wedding.estate.name}.".html_safe
  end

  def character_wedding_invites(character)
    return nil unless character.wedding_invites.size > 0
    list = character.wedding_invites.map{|invite| "#{link_to_character(invite.wedding.bride)} and #{link_to_character(invite.wedding.groom)} on the #{invite.wedding.event_date.to_pretty} at Estate #{invite.wedding.estate.name}" }
    ("#{pronoun(character)} has invited to the following weddings: " + list.join(", ") + ".").html_safe
  end

  def character_proposals(character)
    return nil unless character.proposals.size > 0
    list = character.proposals.map{|c| link_to_character(c) }
    to_or_from = character.male? ? "to" : "from"
    one_or_more = character.proposals.size == 1 ? "a marriage proposal" : "marriage proposals"
    ("#{pronoun(character)} has #{one_or_more} #{to_or_from} " + list.join(", ") + ".").html_safe
  end

  def character_accusations(character)
    return nil unless character.accusations.size > 0
    list = character.accusations.map do |accusation|  
      if accusation.character.id == character.id
        "<p>#{pronoun(character)} has accused #{link_to_character(accusation.accused)} of injustice.</p>"
      else
        "<p>#{pronoun(character)} has been accused by #{link_to_character(accusation.character)} of injustice.</p>"
      end
    end
    (list.join("\n")).html_safe
  end

  def character_apprenticeship_offers(character)
    return nil unless character.apprenticeship_offers.size > 0
    list = character.apprenticeship_offers.map{|app| link_to_character(app.novice) }
    ("#{pronoun(character)} has received offers to mentor the following novices: " + list.join(", ") + ".").html_safe
  end

  def character_apprenticeships_sought(character)
    return nil unless character.apprenticeships_sought.size > 0
    list = character.apprenticeships_sought.map{|app| link_to_character(app.character) }
    ("#{pronoun(character)} has been offered as an apprentice to the following notable individuals: " + list.join(", ") + ".").html_safe
  end

  def character_apprentices(character)
    return nil unless character.apprentices.size > 0
    list = character.apprentices.map{|app| link_to_character(app.novice) }
    ("#{pronoun(character)} is mentor to the following apprentices: " + list.join(", ") + ".").html_safe
  end

  def character_apprenticeship(character)
    return nil unless character.apprenticeship
    "#{pronoun(character)} is an apprentice of #{link_to_character(character.apprenticeship.character)}".html_safe
  end

  def character_adjectives(character)
    return nil if character.dead?
    list = []
    list << loyalty_description(character)
    adj = intimidation_description(character)
    list << adj unless adj.nil?
    adj = influence_description(character)
    list << adj unless adj.nil?
    adj = glory_description(character)
    list << adj unless adj.nil?
    adj = piety_description(character)
    list << adj unless adj.nil?
    adj = honour_description(character)
    list << adj unless adj.nil?
    character.traits.each do |trait|
      list << trait.to_s
    end
    if list.size > 0
      return ("#{pronoun(character)} is known as " + list.join(", ") + ".").html_safe
    end
    nil
  end

  def character_location(character)
    return nil if character.dead? || character.location.nil? || !belongs_to_current_player?(character)
    if character.location.nil?
      desc = "in unknown whereabouts"
    elsif character.location_type == 'Estate'
      if character.prisoner
        desc = "a <strong>prisoner</strong> at #{link_to_estate(character.location)}"
      else
        desc = "resident at #{link_to_estate(character.location)}"
        desc = desc + " (#{link_to_house(character.location.noble_house)})" if character.location_foreign?
      end
    elsif character.location_type == 'Starship'
      desc = "onboard the #{link_to_starship(character.location)} at #{link_to_location(character.location.location)}"
    elsif character.location_type == 'Army'
      desc = "with the #{link_to_army(character.location)} at #{link_to_location(character.location.location)}"
    elsif character.location_type == 'Unit'
      desc = "with the #{link_to_army(character.location.army)} at #{link_to_location(character.location.army.location)}"
    end
    ("#{pronoun(character)} is currently " + desc + ".").html_safe
  end

  def character_wealth(character)
    return nil if character.dead? || character.location.nil? || !belongs_to_current_player?(character)
    "#{pronoun(character)} has a personal fortune of #{money(character.wealth)} and has put aside a pension of #{money(character.pension)}.".html_safe
  end

  def character_reknown(character)
    return nil if character.dead?
    bits = []
    unless character.skills.empty?
      skill_bits = []
      character.skills.each do |skill|
        skill_bits << skill.to_s
      end
      bits << "#{pronoun(character)} is known to have the following talents: #{skill_bits.join(", ")}."
    end
    training_skill = character.currently_training
    if training_skill
      bits << "#{pronoun(character)} is training to become better at #{training_skill.category}."
    end
    bits.join(" ").html_safe
  end

  def character_siblings(character)
    return nil if character.dead?
    siblings = character.siblings
    return nil if siblings.empty?
    ("#{pronoun(character)} has the following brothers and sisters: " + siblings.to_a.map{|sibling| link_to_character(sibling)}.join(", ") + ".").html_safe
  end

  def character_children(character)
    children = character.children
    return nil if children.empty?
    ("#{pronoun(character)} has the following children: " + children.to_a.map{|child| link_to_character(child)}.join(", ") + ".").html_safe
  end
end
