module OrderProcessing
  class HoldTournamentOrder < LordOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Prize (&pound;)", OrderParameter::NUMBER,true)
      new_parameter("Chronums Until Start", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @prize ||= params[0].parameter_value_obj.to_f
      @prize = 0 if @prize < 0
      @chronums ||= params[1].parameter_value_obj.to_i

      return false if @chronums < 1 && fail!("Chronums must be greater than zero")
      return false if !@estate.has_funds?(@prize) && fail!("Must have prize money to hold a tournament")
      true
    end

    def process!
      return false unless processable?
      @event_date = Game.current_date + @chronums
      Tournament.hold!(@estate,@event_date,@prize)
      true
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end

  end
end
