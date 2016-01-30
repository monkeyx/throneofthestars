module ItemsHelper
  def link_to_item(item,quantity=nil,static=false)
    t = quantity.blank? ? item.name : "#{quantity} x #{(item.name.pluralize_if(quantity))}"
    if static
      link_to t, "/Item/#{item.name}?static=true", :rel => 'lightbox', :title => item.name
    else
      link_to t, "/Item/#{item.name}"
    end
  end

  def options_for_items(selected,categories=nil,mobile_only=false)
    if categories
      list = mobile_only ? Item.categories(categories).mobile : Item.categories(categories)
    else
      list = mobile_only ? Item.mobile : Item.all
    end
    id = selected.nil? ? 0 : selected.to_i
    options_from_collection_for_select(list,"id","name",id)
  end
end
