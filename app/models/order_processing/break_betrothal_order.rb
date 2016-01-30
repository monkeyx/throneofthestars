module OrderProcessing
  class BreakBetrothalOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Message (to Baron)",OrderParameter::TEXT_AREA,false)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @betrothed ||= character.betrothed
      @diplomatic_message ||= params[0].parameter_value_obj

      return false if @betrothed.nil? && fail!("Not betrothed")
      true
    end

    def process!
      return false unless processable?
      if character.break_betrothal!
        unless @diplomatic_message.blank?
          msg = Message.new(:from => character, :character => @betrothed.noble_house.baron, :subject => "Engagement with #{@betrothed.display_name} is ended", :content => @diplomatic_message)
          msg.save && msg.action!        
        end
        return true
      end
      false
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      character.is_betrothed?
    end
  end
end
