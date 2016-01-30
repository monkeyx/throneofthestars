module OrderProcessing
  class OfferAllegianceOrder < DiplomaticOfferOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_offer!(tokens)
      character.noble_house.oath_of_allegiance!(@noble_house,tokens)
    end

  end
end
