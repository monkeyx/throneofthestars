module OrderProcessing
  class BreakAllianceOrder < BreakDiplomaticStatusOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_status
    	DiplomaticRelation.of(character.noble_house).with(@other_house).category(DiplomaticRelation::ALLY).accepted.first
    end

    def break!
    	character.noble_house.break_alliance!(@other_house)
    end
  end
end
