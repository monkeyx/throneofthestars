module UnitsHelper
  def link_to_unit(unit)
    link_to unit.name, unit unless unit.nil?
  end

  def options_for_units(selected,army)
    list = army.nil? ? [] : Unit.of(army)
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end
end
