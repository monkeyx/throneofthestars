class FixTradeGoodYields < ActiveRecord::Migration
  def up
  	trade_goods = Item.category(Item::TRADE_GOOD)
  	normal_poor = trade_goods.select{|t| t.normal_yield < t.poor_yield }
  	normal_poor.each do |t|
  		new_normal_yield = (t.poor_yield + 1.1).round(0).to_i
  		Kernel.p "TRADE GOOD #{t.name} BEFORE normal = #{t.normal_yield} poor = #{t.poor_yield} - AFTER normal = #{new_normal_yield}"
  		t.normal_yield = new_normal_yield
  		t.save
  	end
  	rich_normal = trade_goods.select{|t| t.rich_yield < t.normal_yield }
  	rich_normal.each do |t|
  		new_rich_yield = (t.normal_yield + 1.1).round(0).to_i
  		Kernel.p "TRADE GOOD #{t.name} BEFORE rich = #{t.rich_yield} normal = #{t.rich_yield} - AFTER rich = #{new_rich_yield}"
  		t.rich_yield = new_rich_yield
  		t.save
  	end
  end

  def down
  end
end
