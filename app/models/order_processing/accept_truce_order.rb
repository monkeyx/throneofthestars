module OrderProcessing
  class AcceptTruceOrder < AcceptDiplomaticOfferOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_offer
      @noble_house.current_truce(@other_house)
    end
  end
end
