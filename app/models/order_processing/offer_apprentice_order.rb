module OrderProcessing
  class OfferApprenticeOrder < EmissaryOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Novice", OrderParameter::OWN_CHARACTER,true)
       new_parameter("Noble House", OrderParameter::NOBLE_HOUSE_INCLUDE_ANCIENT,true)
       new_parameter("Character", OrderParameter::CHARACTER,true)
       new_parameter("Message (to Baron)",OrderParameter::TEXT_AREA,false)
    end

    def processable?
      return false unless super

      @novice ||= params[0].parameter_value_obj
      @master ||= params[2].parameter_value_obj
      @diplomatic_message ||= params[3].parameter_value_obj
      
      return false if !@novice.can_become_apprentice? && fail!("#{@novice.name} may not become an apprentice")
      return false if !@master.can_have_apprentices? && fail!("#{@master.display_name} may not take on apprentices")
      return false if @novice.male? && @master.female? && !(@master.knight? || @master.captain?) && fail!("#{@novice.name} is not the right gender to become an apprentice of #{@master.display_name}")
      return false if @novice.female? && @master.male? && !(@master.knight? || @master.captain?) && fail!("#{@novice.name} is not the right gender to become an apprentice of #{@master.display_name}")
      true
    end

    def process!
      return false unless processable?
      if Apprentice.offer_apprentice!(character,@novice, @master)
        unless @diplomatic_message.blank?
          msg = Message.new(:from => character, :character => @master.noble_house.baron, :subject => "Offer #{@novice.display_name} as an apprentice to #{@master.display_name}", :content => @diplomatic_message)
          msg.save && msg.action!        
        end
        return true
      end
      true
    end

    def action_points
      4
    end

  end
end
