module OrderProcessing
  class RevokeRightsOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Item", OrderParameter::ITEM,false)
    end

    def processable?
      return false unless super

      @noble_house ||= params[0].parameter_value_obj
      @item ||= params[1].parameter_value_obj

      if @item
        return false if !Authorisation.has_rights?(@estate,@noble_house,@item) && fail!("No authorisation to pick up #{@item.name} at #{@estate.name} given to House #{@noble_house.name}")
      else
        return false if !Authorisation.has_delivery_rights?(@estate, @noble_house) && fail!("No delivery authorisation given to House #{@noble_house.name}")
      end
      true
    end

    def process!
      return false unless processable?
      return false unless @estate.revoke_authorisation!(@noble_house,@item)
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
