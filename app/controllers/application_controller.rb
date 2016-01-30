# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include NumberFormatting

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  helper_method :cache_model, :cache_key, :toolbar_cache_key, :cached?, :toolbar_cached?, :money, :percentage, :time_diff_in_natural_language, :current_player, :current_noble_house, :current_baron, :belongs_to_current_player?, :character_path, :starship_path, :estate_path, :army_path, :promote_path, :message_path, :gm?

  before_filter :update_in_progress

  def tab?(key)
    params[:tab] == key.to_s
  end

  def class_name_sans_controller
    @class_name_sans_controller ||= self.class.name.gsub('Controller','')
  end

  def cache_model
    unless current_noble_house
      "Root_#{class_name_sans_controller}"
    else
      "Root_NobleHouse_#{current_noble_house.id}_#{class_name_sans_controller}"
    end
  end

  def cache_id
    page_str = params[:page].blank? ? '' : "_page#{params[:page]}"
    if cache_model.is_a?(String)
      "#{cache_model}#{page_str}"
    elsif current_noble_house
      "Root_NobleHouse_#{current_noble_house.id}_#{cache_model.class.name}_#{cache_model.id}#{page_str}"
    else
      "Root_#{cache_model.class.name}_#{cache_model.id}#{page_str}"
    end
  end

  def cache_key(key)
    "#{cache_id}_#{key}"
  end

  def toolbar_cache_key
    key = params[:tab].blank? ? 'orders_toolbar' : "#{params[:tab]}_orders_toolbar"
    "#{cache_id}_#{key}"
  end

  def cached?(key=nil)
    if key
      fragment_exist?(cache_key(key))
    else
      fragment_exist?(cache_id)
    end
  end

  def toolbar_cached?
    cached?(toolbar_cache_key)
  end

  def update_in_progress
    if Game.game_locked?
      render '/updating', :layout => false
      return false
    end
    true
  end

  def gm?
    current_player && current_player.gm?
  end
  
  private

  def current_player_session
    return @current_player_session if defined?(@current_player_session)
    @current_player_session = PlayerSession.find
    @current_player_session
  end
  
  def current_player
    return @current_player if defined?(@current_player)
    @current_player = current_player_session && current_player_session.record
  end

  def current_noble_house
    return @current_noble_house if defined?(@current_noble_house)
    @current_noble_house = current_player.noble_house if current_player && current_player.noble_house && current_player.noble_house.active
  end

  def current_baron
    return @current_baron if defined?(@current_baron)
    @current_baron = current_noble_house.baron if current_noble_house
  end

  def belongs_to_current_player?(model)
    return false unless current_player || model.nil?
    return false unless current_noble_house
    return true unless model.respond_to?(:player) || model.respond_to?(:noble_house)
    return model.player_id == current_player.id if model.respond_to?(:player_id)
    return model.noble_house_id == current_noble_house.id if model.respond_to?(:noble_house_id)
  end

  def redirect_if_unauthorized(model)
    unless belongs_to_current_player?(model)
      redirect_to root_url
      return true
    end
    false
  end

  def require_player
    if current_player.nil?
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_player_session_url
      return false
    end
    true
  end

  def require_gm
    return unless require_player
    unless current_player.gm?
      store_location
      flash[:notice] = "You are not the GM"
      redirect_to root_url
      return false
    end
    true
  end

  def require_noble_house
    return false unless require_player
    if current_noble_house.nil?
      redirect_to new_noble_house_url
      return false
    elsif current_noble_house.baron.nil? || current_noble_house.baron.dead?
      flash[:notice] = "Unfortunately, House #{current_noble_house.name} had no rightful heirs and is now a footnote in the history books. You may start a new house immediately. Better luck this time!"
      current_noble_house.player = nil
      current_noble_house.save!
      redirect_to new_noble_house_url
      return false
    end
    true
  end

  def require_no_player
    if current_player
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
    true
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    if options[:rails_env] == 'development'
      cmd = "start rake #{task} #{args.join(' ')} --trace >> #{Rails.root}/log/rake.log"
    else
      cmd = "/usr/bin/rake #{task} #{args.join(' ')} --trace >> #{Rails.root}/log/rake.log &"
    end
    Kernel.p "call_rake: " + cmd
    system cmd
  end

  def army_path(army,args=nil)
    return nil unless army
    "/Army/#{army.guid}"
  end

  def edit_army_path(army,args=nil)
    return nil unless army
    "/Army/#{army.guid}/edit"
  end

  def unit_path(unit,args=nil)
    return nil unless unit
    "/Army/#{unit.army.guid}/units/#{unit.id}"
  end

  def edit_unit_path(unit,args=nil)
    return nil unless unit
    "/Army/#{unit.army.guid}/units/#{unit.id}/edit"
  end

  def estate_path(estate,args=nil)
    return nil unless estate
    "/Estate/#{estate.guid}"
  end

  def edit_estate_path(estate,args=nil)
    return nil unless estate
    "/Estate/#{estate.guid}/edit"
  end

  def character_path(character,args=nil)
    return nil unless character
    "/Character/#{character.guid}"
  end

  def edit_character_path(character,args=nil)
    return nil unless character
    "/Character/#{character.guid}/edit"
  end

  def starship_path(starship,args=nil)
    return nil unless starship
    "/Starship/#{starship.guid}"
  end

  def edit_starship_path(starship,args=nil)
    return nil unless starship
    "/Starship/#{starship.guid}/edit"
  end

  def promote_path(character,args=nil)
    return nil unless character
    "/Character/#{character.guid}/promote"
  end

  def message_path(message,args=nil)
    return nil unless message
    "/Message/#{message.guid}"
  end
end
