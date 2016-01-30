class WorldsController < ApplicationController
  respond_to :html, :js
  
  def show
    if params[:name]
      @world = World.find_by_name(params[:name])
    elsif params[:id]
      @world = World.find(params[:id])
    else
      redirect_to :action => :index
    end
    if @world
      @market_items = MarketItem.market_stats(@world) if tab?(:world_market) && !cached?
      @own_market_items = MarketItem.at(@world).belongs_to(current_noble_house).order_by_item_name_then_price if current_noble_house && tab?(:listings)
    end
  end

  def index
    @worlds = World.all(:order => 'distance ASC') unless cached?
    @worlds_markets = MarketItem.system_market_stats if tab?(:markets) && !cached?
  end

  def cache_model
    @world || super
  end
end
