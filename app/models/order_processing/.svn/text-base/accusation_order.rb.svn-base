module OrderProcessing
  class AccusationOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Character", OrderParameter::CHARACTER,true)
      new_parameter("Message (to Baron)",OrderParameter::TEXT_AREA,false)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @target ||= params[1].parameter_value_obj
      @diplomatic_message ||= params[2].parameter_value_obj

      return false if @target.noble_house.ancient? && fail!("You cannot make accusations against ancient houses. No cassus belli is needed against them either.")
      true
    end

    def process!
      return false unless processable?
      if Accusation.accuse!(character,@target)
        unless @diplomatic_message.blank?
          msg = Message.new(:from => character, :character => @target.noble_house.baron, :subject => "Demand for Justice!", :content => @diplomatic_message)
          msg.save && msg.action!        
        end
        return true
      end
      false
    end

    def action_points
      2
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      true
    end
  end
end
