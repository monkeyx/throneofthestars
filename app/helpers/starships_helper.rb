module StarshipsHelper
  def link_to_starship(starship)
    return starship.name unless belongs_to_current_player?(starship)
    link_to starship.name, starship_path(starship) unless starship.nil?
  end

  def options_for_starships(selected,house, location=nil,show_debris=true)
    list = []
    if house.nil? && location
      list = show_debris ? Starship.at(location) : Starship.at(location).not_debris
    else
      if location
        list = show_debris ? Starship.of(house).at(location) : Starship.of(house).at(location).not_debris
      else
        list = show_debris ? Starship.of(house) : Starship.of(house).not_debris
      end
    end
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end

  def starship_integrity(starship)
    if starship.debris?
      return "This is a debris field."
    end
    if starship.hulls_assembled < starship.hull_size
      return "This ship is under construction."
    end
    if starship.hull_integrity <= 20
      return "This ship is critically damaged at #{starship.hull_integrity}% hull integrity and will likely suffer an integrity breakdown shortly - #{starship.integrity_breakdown_chance.pp}."
    elsif starship.hull_integrity <= 50
      return "This ship has suffered severe damage and is on #{starship.hull_integrity}% hull integrity."
    elsif starship.hull_integrity <= 80
      return "This ship is moderately damaged and is on #{starship.hull_integrity}% hull integrity."
    elsif starship.hull_integrity < 100
      return "This ship is lightly damaged and is on #{starship.hull_integrity}% hull integrity."
    else
      return "This ship is at #{starship.hull_integrity}% hull integrity."
    end
  end

  def starship_capacity(starship)
    s = ''
    if starship.worker_space_total > 0
      s = s + "It is carrying #{starship.worker_space_used} workers out of a maximum capacity of #{starship.worker_space_total}.<br/>"
    end
    if starship.troop_space_total > 0
      s = s + "It is carrying #{starship.troop_space_used} troops out of a maximum capacity of #{starship.troop_space_total}.<br/>"
    end
    if starship.cargo_space_total > 0
      s = s + "It is carrying #{starship.cargo_space_used} mass of cargo out of a maximum capacity of #{starship.cargo_space_total}.<br/>"
    end
    if starship.ammo_space_total > 0
      s = s + "It is carrying #{starship.ammo_space_used} mass of ammo out of a maximum capacity of #{starship.ammo_space_total}.<br/>"
    end
    if starship.ore_space_total > 0
      s = s + "It is carrying #{starship.ore_space_used} mass of ores out of a maximum capacity of #{starship.ore_space_total}.<br/>"
    end
    s.html_safe
  end

  def tabulate_ship_sections(sections)
    return "<tr>\n<td colspan='2'>Nothing installed</td>\n</tr>\n".html_safe unless sections && sections.size > 0
    sections_count = {}
    sections.each do |s|
      count = sections_count[s.item]
      count = 0 unless count
      count += s.quantity
      sections_count[s.item] = count
    end
    html = ""
    sections_count.keys.sort{|a,b| a.name <=> b.name}.each do |item|
      html += "<tr>\n<td>#{link_to_item(item)}</td>\n<td>#{sections_count[item]}</td>\n</tr>\n"
    end
    html.html_safe
  end
end
