module ScansHelper
  def options_for_scanned_starships(selected,house, location=nil)
    list = []
    if house.nil?
      list = Scan.at(location) if location
    else
      if location
        list = Scan.by_house(house).at(location)
      else
        list = Scan.by_house(house)
      end
    end
    list = list.map{|scan| scan.target}.uniq
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end
end
