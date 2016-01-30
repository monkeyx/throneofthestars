class BuildingTypesController < ApplicationController
  def index
    @databank = true
    @building_types = BuildingType.paginate(:page => params[:page]).order('id ASC') unless cached?
  end

  def show
    @databank = true
    @building_type = nil
    if params[:name]
      @building_type = BuildingType.find_by_category(params[:name])
    elsif params[:id]
      @building_type = BuildingType.find(params[:id])
    else
      redirect_to :action => :index
    end
    render :layout => 'static' unless @building_type.nil? || params[:static].blank?
  end

  def cache_model
    @building_type || super
  end
end
