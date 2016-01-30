class EstatesController < ApplicationController
  respond_to :html, :js
  
  before_filter :store_location
  before_filter :require_noble_house
  
  def index
    unless cached?
      @estates = current_noble_house && Estate.where(:noble_house_id => current_noble_house.id).paginate(:page => params[:page]).order('name ASC')
      if @estates.size == 1
          redirect_to estate_path(@estates.first)
      end
    end
  end

  def show
    @estate = params[:guid] ? Estate.find_by_guid(params[:guid]) : Estate.find(params[:id])
    return if redirect_if_unauthorized(@estate)
    update if params[:estate]
  end

  def update
    @estate = params[:guid] ? Estate.find_by_guid(params[:guid]) : Estate.find(params[:id])
    return if redirect_if_unauthorized(@estate)
    old_name = @estate.name
    if @estate.update_attributes!(:name => params[:estate][:name])
      flash[:notice] = "Estate #{old_name} is now called #{@estate.name}"
      redirect_to estate_path(@estate)
    else
      flash[:error] = "Failed to update estate name."
      redirect_to estate_path(@estate)
    end
  end

  def cache_model
    @estate || super
  end
end
