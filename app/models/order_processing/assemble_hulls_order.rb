module OrderProcessing
  class AssembleHullsOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Starship", OrderParameter::OWN_STARSHIP,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @starship ||= params[0].parameter_value_obj

      shipyards = BuildingType.category(BuildingType::SHIPYARD).first

      return false if !character.location_estate? && fail!("Must be at an estate to assemble a starship")
      return false if @starship.at_same_estate?(character) && fail!("Must be at same estate as the starship")
      return false if @starship.built? && fail!("Starship #{@starship.name} is already built")
      return false if !@estate.has_building?(shipyards) && fail!("Must have shipyards to build a starship")
      return false if @estate.count_item(@starship.hull_type) < 1 && fail!("Estate must have at least one #{@starship.hull_type.name} in inventory")
      true
    end

    def process!
      return false unless processable?
      shipwright = character.skill_rank(Skill::NAVAL_SHIPWRIGHT)
      hulls_assembled = 5 + (5 * shipwright)
      fail!("No hulls assembled") unless @starship.assemble!(hulls_assembled)
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      character.location_estate?
    end
  end
end
