module OrderProcessing
  class AttackHouseShipOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE_INCLUDE_ANCIENT,true)
      new_parameter("Hull Type", OrderParameter::ITEM, false)
      new_parameter("Min Hull Size", OrderParameter::NUMBER, false)
      new_parameter("Max Hull Size", OrderParameter::NUMBER, false)
      new_parameter("Min Hull Damage", OrderParameter::NUMBER, false)
      new_parameter("Max Hull Damage", OrderParameter::NUMBER, false)
    end

    def processable?
      return false unless super

      @target_house ||= params[0].parameter_value_obj
      @hull_type ||= params[1].parameter_value_obj
      @min_hull_size = params[2].parameter_value_obj
      @min_hull_size = @min_hull_size.to_i if @min_hull_size
      @max_hull_size = params[3].parameter_value_obj
      @max_hull_size = @max_hull_size.to_i if @max_hull_size
      @min_hull_damage = params[4].parameter_value_obj
      @min_hull_damage = @min_hull_damage.to_i if @min_hull_damage
      @max_hull_damage = params[4].parameter_value_obj
      @max_hull_damage = @max_hull_damage.to_i if @max_hull_damage

      return false if !character.noble_house.at_war?(@target_house) && fail!("Must be at war")
      return false if !@starship.orbiting? && fail!("Must be in orbit")
      return false if @min_hull_size && @min_hull_size < 1 && fail!("Hull size cannot be lower than zero")
      return false if @max_hull_size && @max_hull_size < 1 && fail!("Hull size cannot be lower than zero")
      return false if @min_hull_damage && @min_hull_damage < 1 && fail!("Hull damage cannot be lower than zero")
      return false if @max_hull_damage && @max_hull_damage < 1 && fail!("Hull damage cannot be lower than zero")
      return false if @min_hull_damage && @min_hull_damage > 99 && fail!("Hull damage cannot be higher than 99")
      return false if @max_hull_damage && @max_hull_damage > 99 && fail!("Hull damage cannot be higher than 99")
      true
    end

    def process!
      return false unless processable?
      @min_hull_size = 1 unless @min_hull_size
      @max_hull_size = 1000 unless @max_hull_size
      @min_hull_damage = 0 unless @min_hull_damage
      @max_hull_damage = 99 unless @max_hull_damage
      return true if @starship.attack_house_ship!(@target_house,@hull_type,@min_hull_size,@max_hull_size,@min_hull_damage,@max_hull_damage)
      fail!("No target found")
      false
    end

    def action_points
      4
    end
  end
end
