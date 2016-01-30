module EstatesHelper
  def link_to_estate(estate)
    return "Estate #{estate.name}" unless belongs_to_current_player?(estate)
    link_to "Estate #{estate.name}", estate_path(estate) unless estate.nil?
  end

  def options_for_estates(selected, house, region=nil, world=nil)
    list = []
    if house.nil?
      list = Estate.at(region) if region
      list = Estate.on(world) if world && region.nil?
    else
      list = Estate.of(house).at(region) if region
      list = Estate.of(house).on(world) if world && region.nil?
      list = Estate.of(house) if world.nil? && region.nil?
    end
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end

  def population_savings_description(spp)
    return "Impoverished (&lt; &pound;100)".html_safe if spp <= 100
    return "Subsistence (&pound;100 - &pound;500)".html_safe if spp <= 500
    return "Average (&pound;500 - &pound;2500)".html_safe if spp <= 2500
    return "Prospering (&pound;2500 - &pound;5000)".html_safe if spp <= 5000
    "Rich (&gt; &pound;5000)".html_safe
  end
end
