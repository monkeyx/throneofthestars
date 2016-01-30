module ItemContainer
  def dummy_container?
    false
  end

  def empty?
    ItemBundle.at(self).size < 1
  end

  def items
    ItemBundle.at(self).map{|ib| ib.item}
  end

  def bundles
    ItemBundle.at(self)
  end

  def bundles_of(item)
    ItemBundle.at(self).of(item)
  end

  def bundles_of_type(category)
    ItemBundle.at(self).of_type(category)
  end

  def add_item!(item,quantity)
    ItemBundle.add_item!(self,item,quantity) unless dummy_container?
  end

  def remove_item!(item,quantity)
    ItemBundle.subtract_item!(self, item, quantity) unless dummy_container?
  end

  def count_all_items
    return 0 if dummy_container?
    total = 0
    items.each{|item| total += count_item(item)}
    total
  end

  def count_item(item)
     dummy_container? ? 0 : ItemBundle.count_items(self, item)
  end

  def sum_items(items)
    return 0 if dummy_container?
    total = 0
    items.each {|item| total += count_item(item)}
    total
  end

  def sum_item_attributes(function)
    return 0 if dummy_container?
    ItemBundle.at(self).to_a.sum{|ib| ib.item.send(function)}
  end

  def distinct_item_attributes(function)
    return [] if dummy_container?
    values = []
    ItemBundle.at(self).each {|ib| values << ib.item.send(function)}
    values.uniq
  end

  def frequency_item_attributes(function)
    return {} if dummy_container?
    values = {}
    ItemBundle.at(self).each do |ib|
      v = ib.item.send(function)
      count = values[v] ? values[v] : 0
      values[v] = count + ib.quantity
    end
    values
  end

  def sum_qualified_item_attributes(qualifying_function, metric_function)
    return 0 if dummy_container?
    total = 0
    ItemBundle.at(self).each do |ib|
      total += ib.item.send(metric_function) if ib.item.send(qualifying_function)
    end
    total
  end

  def sum_category_quantity(category)
    return 0 if dummy_container?
    ItemBundle.at(self).of_type(category).to_a.sum{|ib| ib.quantity}
  end

  def sum_categories_quantity(categories)
    return 0 if dummy_container?
    total += 0
    categories.each {|category| total += sum_category_quantity(category)}
    total
  end

  def sum_mass_category(category)
    return 0 if dummy_container?
    ItemBundle.at(self).of_type(category).to_a.sum{|ib| ib.total_mass}
  end

  def sum_mass_categories(categories)
    return 0 if dummy_container?
    total = 0
    categories.each {|category| total += sum_mass_category(category)}
    total
  end

  def space_available(category)
    Item::MAX_QUANTITY
  end

  def space_available_for(item)
    return 0 if item.nil?
    dummy_container? ? Item::MAX_QUANTITY : (space_available(item.category)/item.mass).to_i
  end

  def transfer_items!(to, item, quantity)
    return 0 if item.immobile?
    max = count_item(item)
    quantity = max if quantity > max
    max = to.space_available_for(item)
    quantity = max if quantity > max
    transaction do
      to.add_item!(item,quantity)
      remove_item!(item,quantity)
    end
    quantity
  end
end
