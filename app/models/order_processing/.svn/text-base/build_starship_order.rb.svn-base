module OrderProcessing
  class BuildStarshipOrder < ManagementOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Starship Configuration", OrderParameter::STARSHIP_CONFIGURATION,true)
      new_parameter("Name", OrderParameter::TEXT,true)
    end

    def processable?
      return false unless super

      @starship_configuration ||= params[0].parameter_value_obj
      @name ||= params[1].parameter_value_obj.to_s

      shipyards = BuildingType.category(BuildingType::SHIPYARD).first

      return false if !@estate.has_building?(shipyards) && fail!("Must have shipyards to build a starship")
      return false if (@starship_configuration.starship_type.project_required && !@estate.current_world.has_project?(@starship_configuration.starship_type.project_required)) && fail!("World Project '#{@starship_configuration.starship_type.project_required}' missing")
      true
    end

    def process!
      return false unless processable?
      @starship = Starship.build_starship!(name, starship_configuration, estate, fully_assembled=false)
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
