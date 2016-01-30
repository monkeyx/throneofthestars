module OrderProcessing
  class RejectDiplomaticOfferOrder < BaronOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
    end

    def diplomatic_offer
      raise "To implement in sub class!"
    end

    def processable?
      return false unless super

      @other_house ||= params[0].parameter_value_obj
      @diplomatic_offer ||= diplomatic_offer

      return false if (@diplomatic_offer.nil? || @diplomatic_offer.accepted?) && fail!("No offer to reject")
      true
    end

    def process!
      return false unless processable?
      return true unless @diplomatic_offer.reject!(character) == false
      false
    end

    def action_points
      0
    end

  end
end
