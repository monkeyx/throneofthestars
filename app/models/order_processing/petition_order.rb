module OrderProcessing
  class PetitionOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
       new_parameter("Character", OrderParameter::CHARACTER_ESTATE,true)
       new_parameter("Bribe &pound;", OrderParameter::NUMBER, false)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @estate ||= character.current_estate
      @noble_house ||= @estate.noble_house if @estate

      return false if !@estate && fail!("Must be at an estate")
      return false if character.emissary? && !@estate.foreign_to?(character) && fail!("Not at a foreign estate")
      
      @target ||= params[0].parameter_value_obj
      @bribe ||= params[1].parameter_value_obj
      @bribe = @bribe.to_f if @bribe

      return false if !@target.at_same_estate?(character) && fail!("Target must be at the same estate")
      return false if (@target.baron? || @target.baroness?) && fail!("May not petition a Baron or Baroness")
      return false if (@target.lord? || @target.lady?) && fail!("May not petition a Lord or Lady")
      if @bribe
        return false if @bribe < 0 && fail!("Bribe must be equal to or greater than zero")
        return false if @bribe > character.noble_house.wealth && fail!("Insufficient funds for the bribe")
      end
      true
    end

    def process!
      return false unless processable?
      character.petition!(@target,@bribe)
    end

    def action_points
      4
    end

    def valid_for_character?
      character.emissary_or_tribune?
    end

  end
end
