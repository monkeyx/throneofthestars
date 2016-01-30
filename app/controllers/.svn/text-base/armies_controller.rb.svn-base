class ArmiesController < ApplicationController
  respond_to :html, :js
  
  before_filter :store_location
  before_filter :require_noble_house
  
  def index
    unless cached?
      @armies = current_noble_house && Army.where(:noble_house_id => current_noble_house.id).paginate(:page => params[:page]).order('name ASC')
      if @armies.size == 1
        redirect_to army_path(@armies.first)
      end
    end
  end

  def show
    @army = params[:guid] ? Army.find_by_guid(params[:guid]) : Army.find(params[:id])
    return if redirect_if_unauthorized(@army)
    update if params[:army]
  end

  def update
    @army = params[:guid] ? Army.find_by_guid(params[:guid]) : Army.find(params[:id])
    return if redirect_if_unauthorized(@army)
    old_name = @army.name
    if @army.update_attributes(:name => params[:army][:name])
      flash[:notice] = "Army #{old_name} is now called #{@army.name}"
      redirect_to army_path(@army)
    else
      flash[:error] = "Failed to update army name."
      redirect_to army_path(@army)
    end
  end

  def cache_model
    @army || super
  end
end
