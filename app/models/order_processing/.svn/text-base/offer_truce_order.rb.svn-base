module OrderProcessing
  class OfferTruceOrder < DiplomaticOfferOrder
    def initialize(order)
      super(order)
    end

    def show_oath_parameter
      true
    end

    def processable?
      return false unless super
      
      return false if !character.noble_house.at_war?(@noble_house) && fail!("Not at war with House #{@noble_house.name}")
      true
    end

    def diplomatic_offer!(tokens)
      character.noble_house.offer_truce!(@noble_house,tokens)
    end

  end
end
