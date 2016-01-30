module NewsHelper
  include NewsLog
  
  def news_content(news,highlight_public_news=false)
    return if news.nil?
    desc = news.description
    if ['/?tab=news', '/empire?tab=news', '/church?tab=news','/announcements','/announcements?tab=announcements','/announcements?tab=births','/announcements?tab=matured','/announcements?tab=marriages','/announcements?tab=deaths'].include?(request.fullpath)  &&
        (current_noble_house.nil? || news.noble_house_id != current_noble_house.id)
      desc = desc + " " + link_to(image_tag('right_arrow_black.png', :alt => '', :title => "Read more House #{news.noble_house.name} news"),"/House/#{news.noble_house.name}")
    end
    unless current_noble_house.nil? || (news.noble_house.id != current_noble_house.id && !highlight_public_news)
      if news.empire?
        return "<span class='empire_news'>#{desc}</span>".html_safe
      elsif news.church?
        return "<span class='church_news'>#{desc}</span>".html_safe
      end
    end
    desc.html_safe
  end
end
