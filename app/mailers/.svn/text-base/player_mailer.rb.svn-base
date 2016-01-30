class PlayerMailer < ActionMailer::Base
  default :from => "\"Throne of the Stars\"<gm@thronestars.com>"

  def setup(player, subject, no_settings=false)
    @player = player
    @subject = "Throne of the Stars: #{subject}"
    @greeting = "Hi #{player.name},"
    @root_url = root_url
    @settings_url = root_url + edit_player_path(:current) unless no_settings
    @unsubscribe_url = unsubscribe_url(player)
    @username = player.username
    @noble_house = player.noble_house
    @login_url = root_url + login_path
  end

  def send_email
    if Rails.env == 'development'
      mail(:subject => "[development] #{@subject} (for #{@player.email_with_name})", :to => "\"Throne of the Stars\"<gm@thronestars.com>")
    else
      mail(:subject => @subject, :to => @player.email_with_name)
    end
  end

  def password_reset_instructions(player)
    setup(player,"Password Reset Instructions",false)
    @edit_password_reset_url = root_url + edit_password_path(player.perishable_token)
    send_email
  end

  def confirm_email(player)
    setup(player, "Confirm Email Address",false)
    @confirm_url = confirm_url(player.confirm_code)
    send_email
  end

  def signup_complete(player)
    setup(player,"Welcome",false)
    send_email
  end

  def house_ceased(player, inherited_by)
    setup(player, "End of House")
    @inherited_by = inherited_by
    send_email
  end

  def house_news(player, news)
    setup(player, "House #{player.noble_house.name} News")
    @news = news
    send_email
  end

  def player_message(player, message)
    setup(player, "New Player Message")
    @message = message
    @message_url = root_url + "/Message/#{@message.guid}"
    send_email
  end

  def newsletter(player, edition, content)
    setup(player, "Newsletter #{edition}")
    @edition = edition
    @content = content
    send_email
  end

  def root_url
    "http://" + $ROOT_URL
  end

  def unsubscribe_url(player)
    root_url + "/unsubscribe/#{player.guid}"
  end

end
