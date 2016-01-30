class ItemsController < ApplicationController
  def index
    @databank = true
    unless cached?
      @items = Item.paginate(:page => params[:page]).order('id ASC')
    end
  end

  def show
    @databank = true
    @item = nil
    if params[:name]
      @item = Item.find_by_name(params[:name])
    elsif params[:id]
      @item = Item.find(params[:id])
    else
      redirect_to :action => :index
    end
    render :layout => 'static' unless @item.nil? || params[:static].blank?
  end

  def cache_model
    @item || super
  end
end
