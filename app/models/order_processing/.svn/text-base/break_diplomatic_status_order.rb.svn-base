module OrderProcessing
  class BreakDiplomaticStatusOrder < BaronOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
    end

    def diplomatic_status
      raise "To implement in sub class!"
    end

    def break!
      raise "To implement in sub class"
    end

    def processable?
      return false unless super

      @other_house ||= params[0].parameter_value_obj
      @diplomatic_status ||= diplomatic_status

      return false if (@diplomatic_status.nil? || !@diplomatic_status.accepted?) && fail!("Nothing to break")
      true
    end

    def process!
      return false unless processable?
      return true unless break! == false
      false
    end

    def action_points
      4
    end

  end
end
