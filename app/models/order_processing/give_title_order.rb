module OrderProcessing
  class GiveTitleOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Estate", OrderParameter::OWN_ESTATE,true)
      new_parameter("Character", OrderParameter::OWN_CHARACTER,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      
      @estate ||= params[0].parameter_value_obj
      @character ||= params[1].parameter_value_obj

      return false if @estate.lord_id != character.id && fail!("#{character.name} is not the Lord of Estate #{@estate.name}")
      return false if !@character.at_same_estate?(@estate) && fail!("Character must be at estate")
      return false if !@character.adult? && fail!("Character must be an adult")
      return false if @character.id == character.id && fail!("Character cannot be self")
      return false if character.baron? && character.estates.size == 1 && fail!("Cannot give away last estate of a Baron")
      true
    end

    def process!
      return false unless processable?
      Title.transfer_lordship!(@character, @estate)
    end

    def action_points
      1
    end

    def valid_for_character?
      character.lord?
    end

  end
end
