class StarshipConfigurationsController < ApplicationController
  respond_to :html, :js
  
  def new
    @databank = true
    @starship_configuration = StarshipConfiguration.new(:noble_house => current_noble_house)
  end

  def create
    @databank = true
    @starship_configuration = StarshipConfiguration.new(params[:starship_configuration])
    if @starship_configuration.save
      flash[:notice] = "Successfully created starship configuration."
      redirect_to @starship_configuration
    else
      render :action => 'new'
    end
  end

  def index
    @databank = true
    unless cached?
      @starship_configurations = current_noble_house ? StarshipConfiguration.where("noble_house_id = #{current_noble_house.id} OR noble_house_id IS NULL").paginate(:page => params[:page]).order('name ASC') : StarshipConfiguration.where("noble_house_id IS NULL").paginate(:page => params[:page]).order('name ASC')
    end
  end

  def show
    @databank = true
    unless cached?
      @starship_configuration = StarshipConfiguration.find(params[:id])
    end
    if @starship_configuration.nil? || (@starship_configuration.noble_house && !belongs_to_current_player?(@starship_configuration))
      flash[:error] = "Unauthorized Access"
      redirect_to :action => :index
    end
  end

  def edit
    @databank = true
    @starship_configuration = StarshipConfiguration.find(params[:id])
    if @starship_configuration.nil? || !belongs_to_current_player?(@starship_configuration)
      flash[:error] = "Unauthorized Access"
      redirect_to :action => :index
    end
  end

  def update
    @databank = true
    @starship_configuration = StarshipConfiguration.find(params[:id])
    if @starship_configuration.nil? || !belongs_to_current_player?(@starship_configuration)
      flash[:error] = "Unauthorized Access"
      redirect_to :action => :index
    elsif @starship_configuration.update_attributes(params[:starship_configuration])
      flash[:notice] = "Successfully updated starship configuration."
      redirect_to @starship_configuration
    else
      render :action => 'edit'
    end
  end

  def cache_model
    @starship_configuration || super
  end
end
