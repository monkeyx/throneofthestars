module OrderProcessing
  class DockOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("World", OrderParameter::WORLD,true)
      new_parameter("Region", OrderParameter::REGION,true)
      new_parameter("Estate", OrderParameter::ESTATE,true)
    end

    def processable?
      return false unless super

      @world ||= params[0].parameter_value_obj
      @region ||= params[1].parameter_value_obj
      @target_estate ||= params[2].parameter_value_obj

      return false if !(@starship.location_type == 'World' && @starship.location_id == @world.id) && fail!("Must be in orbit of #{@world.name}")
      return false if @target_estate.region.world.id != @world.id && fail!("Estate must be on #{@world.name}")
      return false if !@starship.can_dock?(@target_estate) && fail!("Ship incapable of docking at #{@target_estate.name}")
      true
    end

    def process!
      return false unless processable?
      @starship.dock!(@target_estate)
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
