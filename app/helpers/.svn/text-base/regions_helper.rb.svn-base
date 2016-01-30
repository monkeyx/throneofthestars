module RegionsHelper
  def link_to_region(region)
    link_to region.name, "/Planet/#{region.world.name}/#{region.name}"
  end

  def options_for_regions(selected,world=nil,signup=false)
    if world
      list = signup ? Region.on(world).signup : Region.on(world)
    else
      list = signup ? Region.signup : []
    end
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","long_name",id)
  end

  def region_resources_description(region)
    rich = []
    poor = []
    region.resources.each do |resource|
      if resource.yield_category == Resource::RICH
        rich << link_to_item(resource.item)
      elsif resource.yield_category == Resource::POOR
        poor << link_to_item(resource.item)
      end
    end
    ("This region is famous for its abundance of " + rich.to_a.join(", ") +" whilst notorious for its lack of " + poor.to_a.join(", ") + ".").html_safe
  end

  def region_estate_description(region)
    return "There are currently no estates in this region" if region.estates.empty?
    ("The following estates make their home here: " + region.estates.to_a.map{|estate| "#{link_to_estate(estate)} (#{link_to_house(estate.noble_house)})"}.join(", ") + ".").html_safe
  end
end
