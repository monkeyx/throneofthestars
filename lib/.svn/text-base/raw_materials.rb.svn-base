module RawMaterials
  def has_raw_materials?
    ItemBundle.at(self).size > 0
  end

  def raw_materials
    ItemBundle.at(self)
  end

  def add_all_raw_materials!(hash)
    hash.each do |item, quantity|
      add_raw_material!(item,quantity)
    end
  end

  def add_raw_material!(item, quantity)
    ItemBundle.add_item!(self, item, quantity)
  end

  def remove_raw_material!(item,quantity)
    ItemBundle.subtract_item!(self, item, quantity)
  end

  def position_has_raw_materials_for(position)
    qty = Item::MAX_QUANTITY
    raw_materials.each do |ib|
      q = ItemBundle.count_items(position, ib.item) / ib.quantity
      qty = qty > q ? q : qty
    end
    qty
  end

  def position_remove_raw_materials!(position,quantity=1)
    raw_materials.each do |ib|
      ItemBundle.subtract_item!(position,ib.item, (ib.quantity * quantity).to_f.round(0).to_i)
    end
  end
end
