# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for :title, page_title.to_s
    content_for :show_title, show_title if show_title
  end

  def show_title?
    content_for? :show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def sortable_table_head(title, key)
    "#{link_to(image_tag('sort_asc.png'),"?order=#{key}_asc")}&nbsp;#{title}&nbsp;#{link_to(image_tag('sort_desc.png'),"?order=#{key}_desc")}".html_safe
  end

  def order_toolbar(character, order_codes, position = nil)
    orders = []
    order_codes.each do |code|
      orders << render(:partial => '/characters/choose_order', :locals => {:character => character, :order_code => code, :position => position})
    end
    content_for :order_toolbar, orders.join("\n").html_safe
  end

  def show_order_toolbar?
    content_for? :order_toolbar
  end

  def bbcode(content)
    Message.styled_quotes(Message.image_emoticons(content.bbcode_to_html)).html_safe
  end

  def tabbed_menu(tabs,links=[])
    html = "<ul class='tablist'>\n"
    first_tab_current = params[:tab].blank?
    tabs.keys.each do |key|
      klass = 'tab_item'
      klass = klass + ' first' if tabs.keys.first == key
      if params[:tab] == key.to_s || first_tab_current
        klass = klass + ' current'
        first_tab_current = false
      end
      html += "<li class=\"#{klass}\" id=\"tab_item_#{key}\">"
      html += link_to(tabs[key],"?tab=#{key}",:remote => true)
      html += "</li>\n"
    end
    links.each do |link|
      html += "<li>#{link}</li>\n"
    end
    html += "</ul>\n"
    params[:tab] = nil if params[:tab] && !tabs.keys.map{|k|k.to_s}.include?(params[:tab])
    content_for :tab_menu, html.html_safe
  end

  def tab?(key)
    params[:tab] == key.to_s
  end

  def no_tab?
    params[:tab].blank?
  end

  def tab(key,default=false,use_cache=true)
    if (no_tab? && default) || tab?(key)
      if use_cache
        cache(cache_key(key)) do 
          yield
        end
      else
        yield
        ''
      end
    end
  end

  def js_tab(content,toolbar=content_for(:order_toolbar))
    js = "$('\#tab-container').html('#{escape_javascript(content)}');
    $('a[rel=\"lightbox\"]').easybox();
    $('.flash').html('');
    $('.flash').hide();
    "
    flash.each do |name, msg|
      js = js + "$('\#flash_#{name}').html('#{escape_javascript(msg)}');\n"
    end
    selected_tab = "\#tab_item_#{params[:tab]}" unless params[:tab].blank?
    selected_tab = ".first" if selected_tab.blank?
    js = js + "$('.tab_item').removeClass('current');\n"
    js = js + "$('#{selected_tab}').addClass('current');\n"
    unless toolbar.blank?
      js = js + "$('\#orders-toolbar').html('#{escape_javascript(toolbar)}');\n"
    end
    js.html_safe
  end

  def quick_nav_select
    options = {'Latest News' => '/?tab=news',
               "House #{current_noble_house.name}" => noble_house_path(current_noble_house), 
               'Characters' => characters_path, 'Estates' => estates_path, 'Armies' => armies_path, 
               'Starships' => starships_path, 'Messages' => messages_path,
               'Settings' => edit_player_path(:current), 'Logout' => logout_path}
    options['Admin'] = '/admin' if gm?
    select_tag 'path', options_for_select(options,request.fullpath), :prompt => 'Go to...', :onchange => "window.open(this.options[this.selectedIndex].value,'_top')".html_safe, :class => 'quick_nav'
  end
end
