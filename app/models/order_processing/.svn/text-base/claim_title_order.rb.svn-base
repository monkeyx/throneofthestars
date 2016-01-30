module OrderProcessing
  class ClaimTitleOrder < BaronOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("World", OrderParameter::WORLD,true)
      new_parameter("Region", OrderParameter::REGION,false)
    end

    def processable?
      return false unless super
      
      @world ||= params[0].parameter_value_obj
      @region ||= params[1].parameter_value_obj

      if @region
        return false if !Title.can_claim_earl?(character, @region) && fail!("Failed to qualify claim to be Earl of #{@region.name}")
      elsif @world
        return false if !Title.can_claim_duke?(character, @world) && fail!("Failed to qualify claim to be Duke of #{@world.name}")
      else
        return false if fail!("No domain chosen for title claim")
      end
      true
    end

    def process!
      return false unless processable?
      if @region
        viscount = character.has_title?(Title::EARL) && !character.has_title?(Title::VISCOUNT)
        character.add_title!(Title::EARL,@region)
        character.add_title!(Title::VISCOUNT) if viscount
      else
        grand_duke = character.has_title?(Title::DUKE) && !character.has_title?(Title::GRAND_DUKE)
        character.add_title!(Title::DUKE,@world)
        character.add_title!(Title::GRAND_DUKE) if grand_duke
      end
      
    end

    def action_points
      1
    end
  end
end
