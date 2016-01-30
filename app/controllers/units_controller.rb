class UnitsController < ApplicationController
  before_filter :require_noble_house
  
  def show
    @unit = Unit.find(params[:id])
    return if redirect_if_unauthorized(@unit.army)
    update if params[:unit]
  end

  def update
    @unit = Unit.find(params[:id])
    return if redirect_if_unauthorized(@unit.army)
    old_name = @unit.name
    if @unit.update_attributes(:name => params[:unit][:name])
      flash[:notice] = "Unit #{old_name} is now called #{@unit.name}"
      redirect_to unit_path(@unit)
    else
      flash[:error] = "Failed to update unit name."
      redirect_to unit_path(@unit)
    end
  end

  def cache_model
    @unit || super
  end
end
