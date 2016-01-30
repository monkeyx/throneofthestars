class PlayerSessionsController < ApplicationController
  before_filter :require_no_player, :only => [:new, :create]
  before_filter :require_player, :only => :destroy
  
  def new
    @player_session = PlayerSession.new
  end

  def create
    @player_session = PlayerSession.new(params[:player_session])
    if @player_session.save
      if @player_session.record.noble_house.nil?
        redirect_to new_noble_house_url
      elsif @player_session.record.noble_house.baron.nil?
        @player_session.record.noble_house = nil
        @player_session.record.save
        redirect_to new_noble_house_url
      elsif !@player_session.record.noble_house.active?
        @player_session.destroy
        flash[:notice] = "Please wait for your new Noble House to be formed. You will be notified by email when it is ready to play."
        redirect_to root_url
      else
        greeting = @player_session.record.noble_house ? @player_session.record.noble_house.baron.display_name : @player_session.record.name
        flash[:notice] = "Welcome back #{greeting}!"
        redirect_to root_url
      end
    else
      @player_session.errors.clear
      flash[:error] = "Invalid credentials. Please check your username and password."
      render :action => 'new'
    end
  end

  def destroy
    current_player_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end
end
