module OrderProcessing
  class DeliverOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Starship",OrderParameter::OWN_STARSHIP,false)
      new_parameter("Estate", OrderParameter::WORLD_ESTATE,false)
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity",OrderParameter::NUMBER,true)
      new_parameter("Install",OrderParameter::BOOLEAN,false)
    end

    def processable?
      return false unless super

      @starship ||= params[0].parameter_value_obj
      @other_estate ||= params[1].parameter_value_obj
      @item ||= params[2].parameter_value_obj
      @quantity ||= params[3].parameter_value_obj.to_i
      @install ||= params[4].parameter_value_obj

      return false if (@starship.nil? && @estate.nil?) && fail!("Must choose either an estate or starship to deliver items")
      if @starship
        space_available = if @install
          @starship.space_to_install(@item)
        else
          @starship.space_available_for(@item)
        end
        @quantity = space_available if space_available < @quantity
        return false if !(@starship.at_same_estate?(character.current_estate) || @starship.orbiting?(@estate.region.world)) && fail!("Starship is not within reach of shuttles")
        return false if @quantity < 1 && fail!("Insufficient space")
      end
      if @other_estate
        return false if @other_estate.id == @estate.id && fail!("Trying to deliver to same estate")
        return false if @other_estate.foreign_to?(character) && !Authorisation.has_delivery_rights?(@other_estate,character.noble_house) && fail!("No delivery authorisation")
      end
      return false if @estate.count_item(@item) < @quantity && fail!("Not enough #{@item.name} at estate")
      unless @starship && @starship.at_same_estate?(character.current_estate)
        return false if @estate.available_shuttle_capacity < @item.mass && fail!("Not enough shuttle capacity")
      end
      return false if @item.immobile? && fail!("Cannot move #{@item.name}")
      true
    end

    def process!
      return false unless processable?
      if @other_estate
        return false unless @estate.shuttle_to_estate!(@other_estate,@item,@quantity)
      elsif @starship
        return false unless @estate.shuttle_to_starship!(@starship,@item,@quantity,@install)
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
