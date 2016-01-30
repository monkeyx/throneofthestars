module StarshipTypesHelper
  def link_to_starship_type(starship_type)
    link_to starship_type.name, "/ShipType/#{starship_type.name}"
  end

  def options_for_starship_types(selected)
    list = StarshipType.all
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end
end
