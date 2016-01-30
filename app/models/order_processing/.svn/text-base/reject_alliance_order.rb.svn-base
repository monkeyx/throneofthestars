module OrderProcessing
  class RejectAllianceOrder < RejectDiplomaticOfferOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_offer
      @noble_house.current_alliance(@other_house)
    end
  end
end
