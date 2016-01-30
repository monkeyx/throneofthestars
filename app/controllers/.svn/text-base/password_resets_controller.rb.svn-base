class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  
  def new
    create if params[:email]
  end

  def edit
    update if params[:player]
  end

  def create
    @player = Player.find_by_email(params[:email])
    if @player
      @player.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
      "Please check your email."
      redirect_to root_url
    else
      flash[:notice] = "No player was found with that email address"
      render :action => :new
    end
  end

  def update
    @player.password = params[:player][:password]
    @player.password_confirmation = params[:player][:password_confirmation]
    if @player.save
      unless PlayerSession.create(@player, true)
        flash[:notice] = "Password successfully updated. Please login using the form below."
        redirect_to login_path
      else
        flash[:notice] = "Password successfully updated"
        redirect_to root_url
      end
    else
      render :action => :edit
    end
  end

  private
  def load_user_using_perishable_token
    @player = Player.find_using_perishable_token(params[:id])
    unless @player
      flash[:notice] = "We're sorry, but we could not locate your account. " +
      "If you are having issues try copying and pasting the URL " +
      "from your email into your browser or restarting the " +
      "reset password process."
      redirect_to root_url
    end
  end
end
