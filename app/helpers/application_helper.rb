# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def version_tag
    vt = "<span class=\"version\">"
    if @version
      vt = vt + "<a href=\"#{$DEV_STATUS_POST}\" target=\"new\">#{Game::VERSION}</a>"
    end
    if Rails.env == 'development'
      vt = vt + "&nbsp;<small style=\"color: \#777;\">Development</small>"
    end
    (vt + "</span>").html_safe
  end

  def link_to_location(location)
    return nil if location.nil?
    return case location.class.name
    when 'Region'
      link_to_region location
    when 'World'
      "#{link_to_world(location)} orbit".html_safe
    when 'Estate'
      link_to_estate location
    when 'Army'
      if location.location_starship?
        "#{link_to_army(location)} onboard #{link_to_starship(location.location)}".html_safe
      else
        "#{link_to_army(location)} at #{link_to_location(location.location)}".html_safe
      end
    when 'Starship'
      "#{link_to_starship(location)} at #{link_to_location(location.location)}".html_safe
    else
      "#{location.class} #{location.name}".html_safe
    end
  end

  def form_error_messages(model)
    if model.errors.any?
      messages = model.errors.full_messages.map{|msg| "<li>#{msg}</li>\n"}.join("\n")
      "<ul id='errorExplanation'>\n#{messages}</ul>\n".html_safe
    end
  end

  def wiki_help(topic, title=topic)
    "#{link_to(image_tag('help.png', :width => 16, :height => 16, :alt => 'Help', :title => 'Learn more about ' + title), $WIKI_BASE+topic, :target => 'help')}".html_safe
  end

  def wiki_help_div(topic,title=topic)
    link = "#{link_to(image_tag('help_big.png', :width => 32, :height => 32, :alt => 'Help', :title => 'Learn more about ' + title), $WIKI_BASE+topic, :target => 'help')}".html_safe
    "<div class='help'>\n#{link}\n</div>\n".html_safe
  end

end
