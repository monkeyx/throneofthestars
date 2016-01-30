class RegionsController < ApplicationController
  respond_to :html, :js
  
  def show
    if params[:world]
      @world = World.find_by_name(params[:world])
      if @world && params[:name]
        @region = Region.find_by_world_id_and_name(@world.id, params[:name])
      end
      if @world.nil?
        redirect_to worlds_path
      elsif @region.nil?
        redirect_to @world
      end
    elsif params[:id]
      @region = Region.find(params[:id])
    else
      redirect_to worlds_path
    end
  end

  def cache_model
    @region || super
  end
end
