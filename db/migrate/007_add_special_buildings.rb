class AddSpecialBuildings < ActiveRecord::Migration
  def up
  	artefact = Item.find_by_name('Artefact')
  	relic = Item.find_by_name('Relic')
  	anomaly = Item.find_by_name('Anomaly')
  	goo = Item.find_by_name('Goo')
  	nanites = Item.find_by_name('Nanites')
  	sm = Item.find_by_name('Structural Module')
  	hm = Item.find_by_name('Habitation Module')
  	factory = BuildingType.create_civil!(BuildingType::FACTORY, Item::ARTISAN_WORKER,10,{sm => 20, artefact => 1, nanites => 1})
  	university = BuildingType.create_worker_recruitment!(BuildingType::UNIVERSITY, Item::FREEMEN_WORKER,250,{sm => 30, hm => 50, anomaly => 1},Item::ARTISAN_WORKER,250)
  	hospital = BuildingType.create_civil!(BuildingType::HOSPITAL, Item::FREEMEN_WORKER,100,{sm => 20, relic => 1, goo => 1})

  	NobleHouse.gm.estates.each do |estate|
  		estate.construct!(factory,true)
  		estate.construct!(university,true)
  		estate.construct!(hospital,true)
  	end
  end

  def down
  end
end
