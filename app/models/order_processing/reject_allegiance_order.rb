module OrderProcessing
  class RejectAllegianceOrder < RejectDiplomaticOfferOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_offer
      @noble_house.current_allegiance(@other_house)
    end
  end
end
