class AddSpecialItems < ActiveRecord::Migration
  def up
  	metals = Item.find_by_name('Metals')
  	carbonite = Item.find_by_name('Carbonite')
  	rare_elements = Item.find_by_name('Rare Elements')
  	artefact = Item.find_by_name('Artefact')
  	relic = Item.find_by_name('Relic')
  	anomaly = Item.find_by_name('Anomaly')
  	cybernetic_mind = Item.create_command!("Cybernetic Mind",1000,{carbonite => 500, rare_elements => 500, relic => 1})
	cybernetic_mind.update_attributes!(:accuracy_modifier => 2)
  	adv_sensor = Item.create_command!("Advanced Sensors",1000,{carbonite => 500, rare_elements => 500, artefact => 1})
  	adv_sensor.update_attributes!(:sensor_power => "4 on 1d10".chance)
  	adv_shields = Item.create_mission!("Advanced Shield Generator",5000,{metals => 3000, rare_elements => 1000, anomaly => 1})
	adv_shields.update_attributes!(:ship_shield_low => "8 on 1d10".chance, :ship_shield_medium => "7 on 1d10".chance, :ship_shield_high => "6 on 1d10".chance)
  end

  def down
  end
end
