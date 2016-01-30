module OrderProcessing
  class ProposeMarriageOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE_INCLUDE_ANCIENT,true)
      new_parameter("Potential Spouse", OrderParameter::SINGLE_FEMALE,true)
      new_parameter("Dowry (&pound;)",OrderParameter::NUMBER, false)
      new_parameter("Message (to Baron)",OrderParameter::TEXT_AREA,false)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @potential_spouse ||= params[1].parameter_value_obj
      @dowry ||= (params[2].parameter_value_obj ? params[2].parameter_value_obj.to_f : nil)
      @diplomatic_message ||= params[3].parameter_value_obj

      return false if !@potential_spouse.single_female? && fail!("Potential spouse must be a single female")
      return false if @dowry && @dowry < 0 && fail!("Dowry cannot be less than zero")
      true
    end

    def process!
      return false unless processable?
      if character.propose!(@potential_spouse,@dowry)
        unless @diplomatic_message.blank?
          msg = Message.new(:from => character, :character => @potential_spouse.noble_house.baron, :subject => "Marriage Proposal to #{@potential_spouse.display_name}", :content => @diplomatic_message)
          msg.save && msg.action!        
        end
        return true
      end
    end

    def action_points
      2
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      character.single_male?
    end
  end
end
