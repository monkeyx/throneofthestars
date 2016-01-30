class OrdersController < ApplicationController
  respond_to :html, :js
  
  before_filter :require_noble_house
  
  def new
    unless params[:code].blank?
      @order = Order.new(:character_id => params[:character_id], :code => params[:code], :special_instruction => Order::NORMAL)
      @character = Character.find(params[:character_id])
      @order.character = @character
      return if redirect_if_unauthorized(@character)
      if @order.nil? || !@order.valid_for_character?
        flash[:error] = "'#{params[:code]}' is not a valid order to give #{@character.display_name}"
        redirect_back_or_default character_order_path(@character)
        return
      end
      @order.prepare(params[:first_parameter])
    else
      redirect_back_or_default character_order_path(@character)
    end
  end

  def create
    @order = Order.new(params[:order])
    @character = @order.character
    return if redirect_if_unauthorized(@character)
    if @order.save
      flash[:notice] = "Successfully submitted #{@order.code} order."
      redirect_to character_order_path(@character)
    else
      render :action => 'new'
    end
  end

  def destroy
    begin
      @order = Order.find(params[:id])
      return if redirect_if_unauthorized(@order && @order.character)
      @order.destroy if @order
      flash[:notice] = "Successfully cancelled #{@order.code} order."
      redirect_to character_order_path(@order.character)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "No such order"
      redirect_to characters_path
    end
  end

  def up
    begin
      @order = Order.find(params[:id])
      return if redirect_if_unauthorized(@order && @order.character)
      if @order.move_up!
        flash[:notice] = "Order moved up queue"
      else
        flash[:error] = "Could not move order up queue"
      end
      redirect_to character_order_path(@order.character)
    rescue
      flash[:error] = "No such order"
      redirect_to characters_path
    end
  end

  def down
    begin
      @order = Order.find(params[:id])
      return if redirect_if_unauthorized(@order && @order.character)
      if @order.move_down!
        flash[:notice] = "Order moved down queue"
      else
        flash[:error] = "Could not move order down queue"
      end
      redirect_to character_order_path(@order.character)
    rescue
      flash[:error] = "No such order"
      redirect_to characters_path
    end
  end

  def character_order_path(character)
    "#{character_path(character)}?tab=orders"
  end
end
