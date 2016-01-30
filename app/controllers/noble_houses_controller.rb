class NobleHousesController < ApplicationController
  respond_to :html, :js
  
  before_filter :no_noble_house, :only => [:new, :create]

  def index
    unless cached?
      if params[:page].blank?
        if current_noble_house
          page = current_noble_house.page_number
          #Kernel.p "!!!!! CURRENT HOUSE PAGE FOR HOUSE = #{page} !!!!"
        else
          page = 1
        end
      else
        page = params[:page]
      end
      if params[:order] == 'glory_desc'
        list_order = "glory DESC"
      elsif params[:order] == 'glory_asc'
        list_order = "glory ASC"
      elsif params[:order] == 'honour_desc'
        list_order = "honour DESC"
      elsif params[:order] == 'honour_asc'
        list_order = "honour ASC"
      elsif params[:order] == 'piety_desc'
        list_order = "piety DESC"
      elsif params[:order] == 'piety_asc'
        list_order = "piety ASC"
      elsif params[:order] == 'name_desc'
        list_order = "name DESC"
      elsif params[:order] == 'name_asc'
        list_order = "name ASC"
      else
        list_order = "glory DESC, honour DESC, piety DESC, name ASC"
      end
      @noble_houses = NobleHouse.where('(ancient = 1 OR active = 1) AND baron_id IS NOT NULL AND baron_id <> 0').paginate(:page => page).order(list_order)
    end
  end

  def new
    @noble_house = NobleHouse.new
    @noble_house.setup_region
  end

  def create
    @noble_house = NobleHouse.new(params[:noble_house])
    @noble_house.update_attributes(:player => current_player, :wealth => NobleHouse::STARTING_CASH, :formed_date => Game.current_date)
    if @noble_house.save
      call_rake(:setup_house, @noble_house.signup_variables_hash)
      flash[:notice] = "Your new Noble House will be created shortly and you will be notified by email when it is ready for you to start playing. Thank you for your patience."
      current_player_session.destroy
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def show
    begin
      if params[:name]
        @noble_house = NobleHouse.find_by_name(params[:name])
      elsif params[:id]
        @noble_house = NobleHouse.find(params[:id])
      else
        redirect_to :action => :index
        return
      end
      unless @noble_house && @noble_house.active?
        redirect_to :action => :index
      end
    rescue Exception => e
      # TODO logging
      Kernel.p "!!! RESCUE #{e.to_s}\n#{e.backtrace.join("\n")}"
      redirect_to :action => :index
    end
  end

  def no_noble_house
    unless current_player && current_noble_house.nil?
      redirect_to root_url
    end
  end

  def cache_model
    @noble_house || super
  end
end
