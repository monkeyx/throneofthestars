module AdminHelper
	def average_market_price(items)
		total = MarketItem.of_items(items).sum{|mi| mi.quantity}
		return "N/A" unless total > 0
		money (MarketItem.of_items(items).sum{|mi| mi.price * mi.quantity} / total)
	end
end
