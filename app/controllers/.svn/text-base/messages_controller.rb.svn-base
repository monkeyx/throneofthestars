class MessagesController < ApplicationController
  respond_to :html, :js
  
  before_filter :require_noble_house, :exclude => [:preview]
  
  def index
    if params[:tab] == 'sent'
      @messages = Message.where(:from_id => current_baron.id).paginate(:page => params[:page]).order('created_at DESC')
    elsif params[:tab] == 'archived'
      @messages = Message.where(:character_id => current_baron.id, :archived => true, :reported => false).paginate(:page => params[:page]).order('created_at DESC')
    else
      @messages = Message.where(:character_id => current_baron.id, :archived => false, :reported => false).paginate(:page => params[:page]).order('created_at DESC')
    end
  end

  def preview
    render :layout => false
  end

  def new
    unless params[:reply_to].blank?
      @reply_to = Message.find_by_guid(params[:reply_to])
      @reply_to.archive! unless @reply_to.archived?
      @message = @reply_to.reply unless @reply_to.nil? || !belongs_to_current_player?(@reply_to.character)
    end
    @to = Character.find_by_guid(params[:baron]) unless params[:baron].blank?
    @message = Message.new(:from => current_baron, :character => @to) unless @message
  end

  def create
    @message = Message.new(params[:message])
    return if redirect_if_unauthorized(@message.from)
    if @message.save && @message.action!
      flash[:notice] = "Sent message to #{@message.character.display_name}."
      redirect_to messages_url
    else
      render :action => 'new'
    end
  end

  def show
    unless params[:guid].blank?
      @message = Message.find_by_guid(params[:guid])
    else
      @message = Message.find_by_id(params[:id])
    end
    unless @message
      redirect_to messages_url
      return
    end
    return destroy if request.delete?
    return report unless params[:report].blank?
    unless belongs_to_current_player?(@message.character)
      return if redirect_if_unauthorized(@message.from)
    end
    @is_from = @message.from.id == current_baron.id
  end

  def destroy
    @message ||= Message.find_by_guid(params[:guid])
    unless @message
      redirect_to :action => :index
      return
    end
    return if redirect_if_unauthorized(@message.character)
    @message.archive!
    flash[:notice] = "Message archived."
    redirect_to messages_url
  end

  def report
    @message ||= Message.find_by_guid(params[:guid])
    unless @message
      redirect_to :action => :index
      return
    end
    return if redirect_if_unauthorized(@message.character)
    @message.reported!
    flash[:notice] = "The message has been reported as spam or inappropriate."
    redirect_to :action => :index
  end
end
