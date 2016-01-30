module OrderProcessing
  class OfferAllianceOrder < DiplomaticOfferOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_offer!(tokens)
      character.noble_house.offer_alliance!(@noble_house,tokens)
    end

  end
end
