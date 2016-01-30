module OrdersHelper

  def options_for_all_orders
    options_for_select(OrderProcessing::BaseOrderProcessor::CODES)
  end

  def options_for_orders(character)
    options_for_select(character.valid_orders)
  end

  def on_change_function(js_function_name,value_id)
    id = '#' + value_id
    "#{js_function_name}('#{id}');".html_safe
  end

  def item_data_link_function(label)
    id = '#' + label + "-help"
    "show_item_data_link('#{id}',this.options[this.selectedIndex].value);".html_safe
  end

  def building_data_link_function(label)
    id = '#' + label + "-help"
    "show_building_data_link('#{id}',this.options[this.selectedIndex].value);".html_safe
  end

  def order_parameter_form_field(f,param)
    case param.parameter_type
    when OrderParameter::TEXT
      f.text_field :parameter_value, {:id => param.label, :size => 32}
    when OrderParameter::TEXT_AREA
      f.text_area :parameter_value, {:id => param.label, :cols => 70, :rows => 10}
    when OrderParameter::NUMBER
      if OrderParameter::KNOWNN_INTEGER_FIELDS.include?(param.label)
        f.number_field :parameter_value, {:id => param.label, :size => 8, :value => param.parameter_value} || 0
      else
        f.text_field :parameter_value, {:id => param.label, :size => 8, :value => param.parameter_value} || 0
      end
    when OrderParameter::BOOLEAN
      f.select :parameter_value, options_for_select(['Yes','No']), {:include_blank => true}, {:id => param.label}
    when OrderParameter::ITEM
      options = case @order.code
      when "Produce"
        options_for_items(param.parameter_value, Item::PRODUCABLE)
      when "Add to Queue"
        options_for_items(param.parameter_value, Item::PRODUCABLE)
      when "Create Unit"
        options_for_items(param.parameter_value, Item::MILITARY, true)
      when "Load Unit"
        options_for_items(param.parameter_value, Item::MILITARY, true)
      when "Unload Unit"
        options_for_items(param.parameter_value, Item::MILITARY, true)
      when "Install Section"
        options_for_items(param.parameter_value, Item::SHIP_SECTIONS, true)
      when "Uninstall Section"
        options_for_items(param.parameter_value, Item::SHIP_SECTIONS, true)
      when "Add Wedding Items"
        options_for_items(param.parameter_value, Item::WEDDING, true)
      when 'Attack House Ship'
        options_for_items(param.parameter_value, [Item::HULL], true)
      when 'Unload Workers'
        options_for_items(param.parameter_value,[Item::WORKER],true)
      when 'Load Cargo'
        options_for_items(param.parameter_value,Item::CARGO_AND_TROOPS,true)
      when 'Unload Cargo'
        options_for_items(param.parameter_value,Item::CARGO_AND_TROOPS,true)
      when 'Deliver'
        options_for_items(param.parameter_value,Item::CARGO_AND_TROOPS,true)
      when 'Pick Up'
        options_for_items(param.parameter_value,Item::CARGO_AND_TROOPS,true)
      when 'Pickup Authorisation'
        options_for_items(param.parameter_value,Item::CARGO_AND_TROOPS,true)
      when 'Revoke Authorisation'
        options_for_items(param.parameter_value,Item::CARGO_AND_TROOPS,true)
      else
        options_for_items(param.parameter_value)
      end
      f.select :parameter_value, options, {:prompt => "Choose Item"}, {:id => param.label, :onchange => item_data_link_function(param.label)}
    when OrderParameter::WORKER_TYPE
      f.select :parameter_value, options_for_select(Item::WORKER_TYPES[1..3], param.parameter_value), {:prompt => "Choose Workers"}, {:id => param.label}
    when OrderParameter::BUILDING_TYPE
      f.select :parameter_value, options_for_building_types(param.parameter_value), {:prompt => "Choose Building Type"}, {:id => param.label, :onchange => building_data_link_function(param.label)}
    when OrderParameter::STARSHIP_TYPE
      f.select :parameter_value, options_for_starship_types(param.parameter_value), {:prompt => "Choose Starship Type"}, {:id => param.label}
    when OrderParameter::STARSHIP_CONFIGURATION
      f.select :parameter_value, options_for_starship_configurations(param.parameter_value), {:prompt => "Choose Starship Configuration"}, {:id => param.label}
    when OrderParameter::SKILL
      f.select :parameter_value, options_for_skills(param.parameter_value), {:prompt => "Choose Skill"}, {:id => param.label}
    when OrderParameter::NOBLE_HOUSE
      f.select :parameter_value, options_for_houses(param.parameter_value, false), {:prompt => "Choose House"}, {:id => 'noble-house', 
          :onchange => on_change_function('populate_characters','noble-house')}
    when OrderParameter::NOBLE_HOUSE_INCLUDE_ANCIENT
      f.select :parameter_value, options_for_houses(param.parameter_value, true), {:prompt => "Choose House"}, {:id => 'noble-house', 
          :onchange => on_change_function('populate_characters','noble-house')}
    when OrderParameter::OWN_CHARACTER
      f.select :parameter_value, options_for_characters(param.parameter_value,@order.character.noble_house), {:prompt => "Choose Character"}, {:id => param.label}
    when OrderParameter::BRIDE
      f.select :parameter_value, options_for_brides(param.parameter_value,@order.character.noble_house), {:prompt => "Choose Bride"}, {:id => param.label}
    when OrderParameter::CHARACTER_ESTATE
      f.select :parameter_value, options_for_characters_at_location(param.parameter_value,@order.character.current_estate,@order.character), {:prompt => "Choose Character"}, {:id => param.label}
    when OrderParameter::CHARACTER
      f.select :parameter_value, options_for_select([],param.parameter_value), {:prompt => "Choose Character"}, {:id => param.label, :class => 'character-selection'}
    when OrderParameter::SINGLE_FEMALE
      f.select :parameter_value, options_for_select([],param.parameter_value), {:prompt => "Choose Character"}, {:id => param.label, :class => 'single-female-selection'}
    when OrderParameter::SINGLE_MALE
      f.select :parameter_value, options_for_select([],param.parameter_value), {:prompt => "Choose Character"}, {:id => param.label, :class => 'single-male-selection'}
    when OrderParameter::PRISONER_ESTATE
      f.select :parameter_value, options_for_prisoners_estate(param.parameter_value,@order.character.current_estate), {:prompt => "Choose Prisoner"}, {:id => param.label}
    when OrderParameter::PRISONER_HOUSE
      f.select :parameter_value, options_for_prisoners_house(param.parameter_value,@order.character.noble_house), {:prompt => "Choose Prisoner"}, {:id => param.label}
    when OrderParameter::WORLD
      f.select :parameter_value, options_for_worlds(param.parameter_value), {:prompt => "Choose World"}, {:id => 'world', :onchange => on_change_function('populate_regions','world')}
    when OrderParameter::REGION
      f.select :parameter_value, options_for_select([],param.parameter_value), {:prompt => "Choose Region"}, {:id => 'region', :onchange => on_change_function('populate_estates','region'), :class => 'region-selection'}
    when OrderParameter::OWN_ESTATE
      f.select :parameter_value, options_for_estates(param.parameter_value,@order.character.noble_house), {:prompt => "Choose Estate"}, {:id => param.label}
    when OrderParameter::WORLD_ESTATE
      f.select :parameter_value, options_for_estates(param.parameter_value,nil,nil,@order.character.current_world), {:prompt => "Choose Estate"}, {:id => param.label}
    when OrderParameter::OWN_ARMY
      f.select :parameter_value, options_for_armies(param.parameter_value,@order.character.noble_house), {:prompt => "Choose Army"}, {:id => param.label, :onchange => on_change_function('populate_units',param.label)}
    when OrderParameter::UNIT
      f.select :parameter_value, options_for_units(param.parameter_value, @order.character.current_army), {:prompt => "Choose Unit"}, {:id => param.label, :class => 'unit-selection'}
    when OrderParameter::OWN_STARSHIP
      if @order.code == 'Board Starship'
        f.select :parameter_value, options_for_starships(param.parameter_value,@order.character.noble_house,nil,false), {:prompt => "Choose Starship"}, {:id => param.label}
      else
        f.select :parameter_value, options_for_starships(param.parameter_value,@order.character.noble_house), {:prompt => "Choose Starship"}, {:id => param.label}
      end
    when OrderParameter::ESTATE
      f.select :parameter_value, options_for_select([],param.parameter_value), {:prompt => "Choose Estate"}, {:id => param.label, :class => 'estate-selection'}
    when OrderParameter::SCANNED_SHIP
      f.select :parameter_value, options_for_scanned_starships(param.parameter_value,@order.character.noble_house,@order.character.current_world), {:prompt => "Choose Starship"}, {:id => param.label}
    when OrderParameter::PROJECT
      f.select :parameter_value, options_for_select(WorldPorject::PROJECT_TYPES,param.parameter_value), {:prompt => "Choose Project"}, {:id => param.label}
    when OrderParameter::LAW
      f.select :parameter_value, options_for_select(Law::LAWS_AND_EDICTS,param.parameter_value), {:prompt => "Choose Law or Edict"}, {:id => param.label}
    when OrderParameter::PERSONAL_COMBAT
      f.select :parameter_value, options_for_select(Character::PERSONAL_COMBAT,param.parameter_value), {:prompt => "Choose Combat Type"}, {:id => param.label}
    when OrderParameter::INFORMATION_TYPE
      f.select :parameter_value, options_for_select(Characters::Emissary::INFORMATION_TYPES,param.parameter_value), {:prompt => "Choose Information Type"}, {:id => param.label}
    end
  end

end
