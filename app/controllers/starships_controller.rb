class StarshipsController < ApplicationController
  respond_to :html, :js
  
  before_filter :store_location
  before_filter :require_noble_house
  
  def index
    unless cached?
      @starships = current_noble_house && Starship.where(:noble_house_id => current_noble_house.id).paginate(:page => params[:page]).order('name ASC')
      if @starships.size == 1
        redirect_to starship_path(@starships.first)
      end
    end
  end

  def show
    @starship = params[:guid] ? Starship.find_by_guid(params[:guid]) : Starship.find(params[:id])
    return if redirect_if_unauthorized(@starship)
    update if params[:starship]
  end

  def update
    @starship = params[:guid] ? Starship.find_by_guid(params[:guid]) : Starship.find(params[:id])
    return if redirect_if_unauthorized(@starship)
    old_name = @starship.name
    if @starship.update_attributes(:name => params[:starship][:name])
      flash[:notice] = "Starship #{old_name} is now called #{@starship.name}"
      redirect_to starship_path(@starship)
    else
      flash[:error] = "Failed to update starship name."
      redirect_to starship_path(@starship)
    end
  end

  def cache_model
    @starship || super
  end

end
