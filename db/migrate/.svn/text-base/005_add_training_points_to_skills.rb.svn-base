class AddTrainingPointsToSkills < ActiveRecord::Migration
  def change
  	add_column :skills, :training_points, :integer, :default => 0
  	Skill.training.each do |skill|
  		points = Game.current_date.difference(skill.training_start_date)
  		skill.update_attributes!(:training_points => points)
  	end
  end
end
