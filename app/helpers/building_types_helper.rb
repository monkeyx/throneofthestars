module BuildingTypesHelper
  def link_to_building_type(building_type,static=false)
  	if static
    	link_to building_type.category, "/BuildingType/#{building_type.category}?static=true", :rel => 'lightbox', :title => building_type.category
    else
    	link_to building_type.category, "/BuildingType/#{building_type.category}"
    end
  end

  def options_for_building_types(selected)
    list = BuildingType.all
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","category",id)
  end
end
