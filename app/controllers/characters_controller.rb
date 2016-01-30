class CharactersController < ApplicationController
  respond_to :html, :js
  
  before_filter :store_location, :except => [:promote]
  before_filter :require_noble_house, :only => [:index]

  def promote
    @character = params[:guid] ? Character.find_by_guid(params[:guid]) : Character.find(params[:id])
    return if redirect_if_unauthorized(@character)
    if @character.major?
      flash[:error] = "#{@character.display_name} is already a major character"
      redirect_back_or_default character_path(@character)
    elsif @character.noble_house.maxed_majors?
      flash[:error] = "House already has #{NobleHouse::MAXIMUM_MAJOR_CHARACTERS} major characters"
      redirect_back_or_default :action => :index
    else
      @character.promote!
      flash[:notice] = "Successfully promoted #{@character.display_name} to a major member of your House"
      redirect_back_or_default character_path(@character)
    end
  end

  def index
    unless cached?
      @characters = current_noble_house && Character.where(:dead => false, :noble_house_id => current_noble_house.id).paginate(:page => params[:page]).order('birth_date ASC')
    end
  end

  def show
    begin
      @character = params[:guid] ? Character.find_by_guid(params[:guid]) : Character.find_by_id(params[:id])
    rescue
      redirect_to root_url
    end
    unless @character
      flash[:error] = "No such character found. If this is in error please <a href=\"mailto:#{$EMAIL_ADDRESS}?subject=No character found #{params[:guid]}\">email the GM</a>.".html_safe
      redirect_to root_url
    end

    update if params[:character]
  end

  def update
    @character = params[:guid] ? Character.find_by_guid(params[:guid]) : Character.find(params[:id])
    return if redirect_if_unauthorized(@character)
    old_name = @character.name
    if @character.update_attributes!(:name => params[:character][:name])
      flash[:notice] = "#{old_name} now goes by the name of #{@character.name}"
      redirect_to character_path(@character)
    else
      flash[:error] = "Failed to update character name."
      redirect_to character_path(@character)
    end
  end

  def cache_model
    @character || super
  end
end
