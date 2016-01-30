class ModelSweeper < ActionController::Caching::Sweeper
	observe Game

	def after_save(record)
		return unless record
		@controller ||= ActionController::Base.new
		Rails.cache.clear
	end
end
