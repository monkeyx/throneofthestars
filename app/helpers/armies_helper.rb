module ArmiesHelper
  def link_to_army(army)
    return army.name unless belongs_to_current_player?(army)
    link_to "#{army.name} Army", army_path(army) unless army.nil?
  end

  def options_for_armies(selected,house,location=nil)
    list = []
    if house.nil?
      list = Army.at(location) if location
    else
      if location
        list = Army.of(house).at(location)
      else
        list = Army.of(house)
      end
    end
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end

  def morale_description(army)
    return "in invincible morale" if army.morale >= 100
    return "in high morale" if army.morale > 90
    return "in good morale" if army.morale > 75
    return "of flagging morale" if army.morale > 50
    return "is depleted" if army.morale > 25
    "close to crack and surrender"
  end
end
