class SeedAncientArtefacts < ActiveRecord::Migration
  def up
  	artefact = Item.find_by_name('Artefact')
  	relic = Item.find_by_name('Relic')
  	NobleHouse.ancient.each do |house|
  		estate = house.home_estate
  		if estate
  			roll = "1d6".roll
  			case roll
  			when 6
  				estate.add_item!(artefact,1)
  				Kernel.p "Estate #{estate.name} got 1 x Artefact"
  			when 5
  				estate.add_item!(relic,1)
  				Kernel.p "Estate #{estate.name} got 1 x Relic"
  			end

  		end
  	end
  end

  def down
  end
end
