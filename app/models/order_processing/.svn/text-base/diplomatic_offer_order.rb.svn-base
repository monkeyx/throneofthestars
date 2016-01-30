module OrderProcessing
  class DiplomaticOfferOrder < EmissaryOrder
    def initialize(order)
      super(order)
    end

    def show_oath_parameter
      false
    end

    def prepare_new_parameters
       new_parameter("Offer Estate", OrderParameter::OWN_ESTATE,false)
       new_parameter("Offer Lands", OrderParameter::NUMBER,false)
       new_parameter("Offer Sovereigns (&pound;)", OrderParameter::NUMBER,false)
       new_parameter("Offer Oath of Allegiance", OrderParameter::BOOLEAN,false) if show_oath_parameter
       new_parameter("Message",OrderParameter::TEXT_AREA,false)
    end

    def processable?
      return false unless super

      @offer_estate ||= params[0].parameter_value_obj
      @offer_lands ||= params[1].parameter_value_obj && params[1].parameter_value_obj.to_i
      @offer_sovereigns ||= params[2].parameter_value_obj && params[2].parameter_value_obj.to_f
      @offer_oath ||= params[3].parameter_value_obj if show_oath_parameter
      @diplomatic_message ||= params[(show_oath_parameter ? 4 : 3)].parameter_value_obj
      
      return false if @noble_house.ancient? && fail!("May not make a diplomatic offer to an ancient house")
      return false if @offer_lands && @offer_lands < 1 && fail!("May not offer less than 1 land")
      return false if @offer_sovereigns && @offer_sovereigns < 1 && fail!("May not offer less than 1 sovereign")
      return false if @offer_lands && !@offer_estate && fail!("Must specify estate from which lands are to be taken")
      return false if @offer_lands && @offer_estate.free_lands < @offer_lands && fail!("Estate #{@offer_estate.name} does not have #{@offer_lands} land to give away")
      true
    end

    def process!
      return false unless processable?
      tokens = []
      if @offer_lands && @offer_estate
        tokens << DiplomaticToken.give_land(@offer_estate,@offer_lands)
      elsif @offer_estate
        tokens << DiplomaticToken.give_estate(@offer_estate)
      end
      tokens << DiplomaticToken.give_sovereigns(@offer_sovereigns) if @offer_sovereigns
      tokens << DiplomaticToken.give_oath if @offer_oath
      unless diplomatic_offer!(tokens) == false
        unless @diplomatic_message.blank?
          msg = Message.new(:from => character, :character => @noble_house.baron, :subject => "#{self.code}", :content => @diplomatic_message)
          msg.save && msg.action!        
        end
        return true 
      end
      false
    end

    def diplomatic_offer!(tokens)
      raise "To implement in sub class!"
    end

    def action_points
      4
    end

  end
end
