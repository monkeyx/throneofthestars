module StarshipConfigurationsHelper
  def link_to_starship_configuration(starship_configuration)
    link_to starship_configuration.name, starship_configuration
  end

  def options_for_starship_configurations(selected)
    list = current_noble_house ? StarshipConfiguration.for_house(current_noble_house) : StarshipConfiguration.public
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end
end
