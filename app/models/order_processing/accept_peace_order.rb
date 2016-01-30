module OrderProcessing
  class AcceptPeaceOrder < AcceptDiplomaticOfferOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_offer
      @noble_house.current_peace(@other_house)
    end
  end
end
