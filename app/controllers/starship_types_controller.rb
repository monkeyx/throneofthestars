class StarshipTypesController < ApplicationController
  def index
    @databank = true
    unless cached?
      @starship_types = StarshipType.all
    end
  end

  def show
    @databank = true
    if params[:name]
      @starship_type = StarshipType.find_by_name(params[:name])
    elsif params[:id]
      @starship_type = StarshipType.find(params[:id])
    else
      redirect_to :action => :index
    end
  end

  def cache_model
    @starship_type || super
  end
end
