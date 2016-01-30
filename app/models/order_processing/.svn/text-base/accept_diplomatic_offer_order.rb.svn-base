module OrderProcessing
  class AcceptDiplomaticOfferOrder < BaronOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
       new_parameter("Land offered add to Estate", OrderParameter::OWN_ESTATE,false)
    end

    def diplomatic_offer
      raise "To implement in sub class!"
    end

    def processable?
      return false unless super

      @other_house ||= params[0].parameter_value_obj
      @estate ||= params[1].parameter_value_obj
      @diplomatic_offer ||= diplomatic_offer

      return false if (@diplomatic_offer.nil? || @diplomatic_offer.accepted?) && fail!("No offer to accept")
      true
    end

    def process!
      return false unless processable?
      return true unless @diplomatic_offer.accept!(character,@estate) == false
      false
    end

    def action_points
      4
    end

  end
end
