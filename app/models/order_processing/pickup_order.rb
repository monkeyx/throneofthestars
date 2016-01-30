module OrderProcessing
  class PickupOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Starship",OrderParameter::OWN_STARSHIP,false)
      new_parameter("Estate", OrderParameter::WORLD_ESTATE,false)
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity",OrderParameter::NUMBER,true)
      new_parameter("Uninstall",OrderParameter::BOOLEAN,false)
    end

    def processable?
      return false unless super

      @starship ||= params[0].parameter_value_obj
      @other_estate ||= params[1].parameter_value_obj
      @item ||= params[2].parameter_value_obj
      @quantity ||= params[3].parameter_value_obj.to_i
      @uninstall ||= params[4].parameter_value_obj

      return false if (@starship.nil? && @estate.nil?) && fail!("Must choose either an estate or starship to pickup items")
      if @starship
        qty_available = if @uninstall
          @starship.count_section(@item)
        else
          @starship.count_item(@item)
        end
        @quantity = qty_available if qty_available < @quantity
        return false if @quantity < 1 && fail!("No such item on starship")
        return false if !(@starship.at_same_estate?(character.current_estate) || @starship.orbiting?(@estate.region.world)) && fail!("Starship is not within reach of shuttles")
      end
      unless @starship && @starship.at_same_estate?(character.current_estate)
        return false if @estate.available_shuttle_capacity < @item.mass && fail!("Not enough shuttle capacity")
      end
      return false if @item.immobile? && fail!("Cannot move #{@item.name}")
      true
    end

    def process!
      return false unless processable?
      if @other_estate
        return false unless @estate.shuttle_from_estate!(@other_estate,@item,@quantity)
      elsif @starship
        return false unless @estate.shuttle_from_starship!(@starship,@item,@quantity,@uninstall)
      else
        return false
      end
      true
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end
  end
end
