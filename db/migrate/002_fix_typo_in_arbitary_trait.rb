class FixTypoInArbitaryTrait < ActiveRecord::Migration
  def up
  	Trait.update_all("category = 'Arbitrary'", :category => 'Arbitary')
  end

  def down
  end
end
