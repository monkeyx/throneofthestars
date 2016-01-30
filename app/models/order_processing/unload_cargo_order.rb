module OrderProcessing
  class UnloadCargoOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("World", OrderParameter::WORLD,true)
      new_parameter("Region", OrderParameter::REGION,true)
      new_parameter("Estate", OrderParameter::ESTATE,true)
      new_parameter("Item", OrderParameter::ITEM,false)
      new_parameter("Quantity", OrderParameter::NUMBER,false)
    end

    def processable?
      return false unless super

      @estate ||= params[2].parameter_value_obj
      @item ||= params[3].parameter_value_obj
      @quantity ||= params[4].parameter_value_obj.to_i

      return false if !@starship.can_trade_with?(@estate) && fail!("Cannot trade with Estate #{@estate.name}")
      return false if @item && @item.immobile? && fail!("Cannot move #{@item.name}")
      true
    end

    def process!
      return false unless processable?
      @starship.unload_cargo!(@estate,@item,@quantity)
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
