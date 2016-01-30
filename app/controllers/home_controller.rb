class HomeController < ApplicationController
  respond_to :html, :js

  def index
  	@version = true
    @home = true
    current_player.read_news! if current_player && tab?(:news)
  	if current_player && !current_player.signup_complete?
      redirect_to new_noble_house_path
      return
    end
    unless cached?
    	@news = current_noble_house ? News.home_news(current_noble_house) : News.empire_and_church
    end
  end
end
