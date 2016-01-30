module OrderProcessing
  class InviteToWeddingOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Bride", OrderParameter::BRIDE,true)
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Guest", OrderParameter::CHARACTER,false)
    end

    def processable?
      return false unless super

      @bride ||= params[0].parameter_value_obj
      @house ||= params[1].parameter_value_obj
      @guest ||= params[2].parameter_value_obj
      @wedding ||= @bride.wedding

      return false if !@wedding || @wedding.estate_id != @estate.id && fail!("May only invite guests to weddings to be held at Estate #{@estate.name}")
      return false if @wedding.past? && fail!("Wedding has already taken place")
      true
    end

    def process!
      return false unless processable?
      if @guest
        @wedding.invite!(@guest)
      else
        @house.characters.each{|c| @wedding.invite!(c) if c.adult? }
      end
      true
    end

    def action_points
      0
    end

    def action_points_on_fail
      0
    end

  end
end
