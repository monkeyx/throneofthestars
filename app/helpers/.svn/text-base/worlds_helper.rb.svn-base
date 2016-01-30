module WorldsHelper
  def link_to_world(world)
    link_to world.name, "/Planet/#{world.name}"
  end

  def options_for_worlds(selected)
    list = World.all
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end

  def world_region_description(world)
    return nil if world.regions.empty?
    "The world consists of the following regions: " + world.regions.to_a.map{|region| link_to_region(region)}.join(", ") + "."
  end
end
