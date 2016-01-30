module OrderProcessing
  class BreakOathOrder < BreakDiplomaticStatusOrder
    def initialize(order)
      super(order)
    end

    def diplomatic_status
    	if character.noble_house.liege.id == @other_house.id
    		DiplomaticRelation.of(character.noble_house).with(@other_house).category(DiplomaticRelation::LIEGE).first
    	else
    		DiplomaticRelation.of(character.noble_house).with(@other_house).category(DiplomaticRelation::VASSAL).first
    	end
    end

    def break!
    	character.noble_house.break_oath!(@other_house)
    end
  end
end
