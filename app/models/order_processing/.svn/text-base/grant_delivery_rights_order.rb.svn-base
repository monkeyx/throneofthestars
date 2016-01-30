module OrderProcessing
  class GrantDeliveryRightsOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
    end

    def processable?
      return false unless super

      @noble_house ||= params[0].parameter_value_obj

      return false if @noble_house.id == character.noble_house_id && fail!("No need to issue delivery authorisations to your own house")
      true
    end

    def process!
      return false unless processable?
      return false unless @estate.issue_delivery_authorisation!(@noble_house)
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
