module OrderProcessing
  class CollectTaxesOrder < LordOrder
    def initialize(order)
      super(order)
      @amount_collected = 0
    end

    def prepare_new_parameters
      new_parameter("Tax Level (&pound;)", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @amount_collected = 0
      @tax_level ||= params[0].parameter_value_obj.to_f

      return false if @tax_level < 0 && fail!("Invalid tax level")
      true
    end

    def process!
      return false unless processable?
      @amount_collected = 0
      @estate.populations.each do |pop|
        @amount_collected += pop.pay_taxes!(@tax_level)
      end
      true
    end

    def action_points
      4
    end

    def action_points_on_fail
      @amount_collected > 0 ? 4 : 0
    end

  end
end
