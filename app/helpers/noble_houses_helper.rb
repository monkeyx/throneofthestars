module NobleHousesHelper
  def link_to_own_house
    return unless current_noble_house
    link_to "House #{current_noble_house.name}", "/House/#{current_noble_house.name}"
  end

  def noble_house_path(house)
    "/House/#{house.name}"
  end

  def link_to_house(house)
    return if house.nil?
    link_to "House #{house.name}", noble_house_path(house)
  end

  def options_for_houses(selected,include_ancient=true,exclude_own_house=true)
    if exclude_own_house
      list = include_ancient ? NobleHouse.active_or_ancient.exclude(current_noble_house).all(:order => 'name ASC') : NobleHouse.active.exclude(current_noble_house).all(:order => 'name ASC')
    else
      list = include_ancient ? NobleHouse.active_or_ancient.all(:order => 'name ASC') : NobleHouse.active.all(:order => 'name ASC')
    end
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name_with_ancient",id)
  end

  def house_wealth_description(noble_house)
    if noble_house.wealth <= 10000
      return "House #{noble_house.name} is considered <strong>impoverished</strong>.".html_safe
    elsif noble_house.wealth <= 100000
      return "House #{noble_house.name} is of <strong>modest means</strong>.".html_safe
    elsif noble_house.wealth <= 500000
      return "House #{noble_house.name} is substantially <strong>prosperous</strong>.".html_safe
    elsif noble_house.wealth <= 1000000
      return "House #{noble_house.name} is decadently <strong>affluent</strong>.".html_safe
    elsif noble_house.wealth <= 5000000
      return "House #{noble_house.name} is quite <strong>wealthy</strong>.".html_safe
    else
      return "House #{noble_house.name} is <strong>rich</strong> and flaunts its opulence.".html_safe
    end
  end
end
