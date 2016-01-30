module OrderProcessing
  class UninstallSectionOrder < CaptainOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Item", OrderParameter::ITEM,true)
      new_parameter("Quantity", OrderParameter::NUMBER,true)
    end

    def processable?
      return false unless super

      @estate ||= @starship.location
      @item ||= params[0].parameter_value_obj
      @quantity ||= params[1].parameter_value_obj.to_i

      return false if !@starship.location_estate? && fail!("Must be docked to uninstall a section")
      return false if @estate.foreign_to?(@starship) && fail!("Must be docked at own estate to uninstall a section")
      return false if !@item.section? && fail!("#{@item.name} is not a valid ship section")
      return false if !@starship.has_section?(@item) && fail!("No #{@item.name} installed")
      true
    end

    def process!
      return false unless processable?
      @starship.uninstall!(@item, @quantity) > 0
    end

    def action_points
      1
    end
  end
end
