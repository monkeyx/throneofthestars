class PlayersController < ApplicationController
  def new
    @player = Player.new
  end

  def confirm
    list = Player.confirm_code(params[:id])
    @player = list.first if list.size > 0
    if @player
      @player.confirm!
      PlayerSession.create(@player, true)
      flash[:notice] = "Thank you for comfirming your email address, you can start creating your own noble house!"
    else
      flash[:error] = "Unknown or inactive confirmation code, please recheck your email."
    end
    redirect_to root_url
  end

  def create
    @player = Player.new(params[:player])
    if @player.save && @player.deliver_confirmation!
      @player.make_gm! if Player.count == 1
      flash[:notice] = "Successfully signed up. Please check your email to confirm (ensure emails from #{$EMAIL_ADDRESS} are not being marked as spam)."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def edit
    @player = current_player
  end

  def update
    @player = current_player
    if @player.update_attributes(params[:player])
      flash[:notice] = "Successfully updated your settings."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end

  def unsubscribe
    @player = Player.find_by_guid(params[:guid])
    if @player && @player.no_email!
      flash[:notice] = "You have been unsubscribed from all emails. If you wish to resubscribe you can do so by logging in and clicking on settings."
    else
      flash[:error] = "No subscriber with those credentials found. Please contact #{$EMAIL_ADDRESS} if you believe this is in error."
    end
    redirect_to root_url
  end
end
