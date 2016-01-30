module OrderProcessing
  class HostWeddingOrder < LordOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Bride", OrderParameter::BRIDE,true)
      new_parameter("Chronums Until Event", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @bride ||= params[0].parameter_value_obj
      @chronums ||= params[1].parameter_value_obj.to_i

      return false if !@bride.female? && fail!("May only host weddings on behalf of the bride")
      return false if !@bride.betrothed && fail!("Character must be betrothed")
      return false if @chronums < 1 && fail!("Chronums must be greater than zero")
      return false if @estate.weddings.select{|wedding| wedding.pending?}.size > 0 && fail!("Only one wedding may be prepared at an estate at any one time")
      true
    end

    def process!
      return false unless processable?
      @event_date = Game.current_date + @chronums
      Wedding.host!(@estate,@bride,@event_date)
      true
    end

    def action_points
      4
    end

    def action_points_on_fail
      0
    end

  end
end
