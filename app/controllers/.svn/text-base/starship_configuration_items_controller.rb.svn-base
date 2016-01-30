class StarshipConfigurationItemsController < ApplicationController
  before_filter :require_noble_house
  
  def new
    @starship_configuration = StarshipConfiguration.find(params[:starship_configuration_id])
    unless @starship_configuration.nil? || !belongs_to_current_player?(@starship_configuration)
      @starship_configuration_item = @starship_configuration.starship_configuration_items.new
    else
      flash[:error] = "Unauthorized access"
      redirect_to starship_configuraiton_path
    end
    
  end

  def create
    @starship_configuration_item = StarshipConfigurationItem.new(params[:starship_configuration_item])
    @starship_configuration = @starship_configuration_item.starship_configuration
    if @starship_configuration.nil? || !belongs_to_current_player?(@starship_configuration)
      flash[:error] = "Unauthorized access"
      redirect_to starship_configuraiton_path
    elsif installed = @starship_configuration.add_sections!(@starship_configuration_item.item, @starship_configuration_item.quantity)
      msg = "Added #{installed} of #{@starship_configuration_item.item.name} to configuration."
      msg = "Insufficient slots in starship type. #{msg}" if installed != @starship_configuration_item.quantity
      flash[:notice] = msg
      redirect_to "#{starship_configuration_path(@starship_configuration_item.starship_configuration)}?tab=sections"
    else
      render :action => 'new'
    end
  end

  def edit
    @starship_configuration_item = StarshipConfigurationItem.find(params[:id])
    @starship_configuration = @starship_configuration_item.starship_configuration
    if @starship_configuration.nil? || !belongs_to_current_player?(@starship_configuration)
      flash[:error] = "Unauthorized Access"
      redirect_to :action => :index
    end
  end

  def update
    @starship_configuration_item = StarshipConfigurationItem.new(params[:starship_configuration_item])
    @starship_configuration = @starship_configuration_item.starship_configuration
    if @starship_configuration.nil? || !belongs_to_current_player?(@starship_configuration)
      flash[:error] = "Unauthorized Access"
      redirect_to :action => :index
    elsif installed = @starship_configuration.update_sections!(@starship_configuration_item.item, @starship_configuration_item.quantity)
      msg = "Set #{installed} of #{@starship_configuration_item.item.name} to configuration."
      msg = "Insufficient slots in starship type. #{msg}" if installed != @starship_configuration_item.quantity
      flash[:notice] = msg
      redirect_to "#{starship_configuration_path(@starship_configuration_item.starship_configuration)}?tab=sections"
    else
      render :action => 'edit'
    end
  end

  def destroy
    @starship_configuration_item = StarshipConfigurationItem.find(params[:id])
    @starship_configuration = @starship_configuration_item.starship_configuration
    if @starship_configuration.nil? || !belongs_to_current_player?(@starship_configuration)
      flash[:error] = "Unauthorized access"
      redirect_to starship_configuraiton_path
    else
      @starship_configuration.remove_sections!(@starship_configuration_item.item)
      flash[:notice] = "Removed #{@starship_configuration_item.item.name} from configuration."
      redirect_to "#{starship_configuration_path(@starship_configuration_item.starship_configuration)}?tab=sections"
    end
  end
end
