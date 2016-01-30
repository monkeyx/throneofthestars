module OrderProcessing
  class InstallSectionOrder < CaptainOrder
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

      return false if !@starship.location_estate? && fail!("Must be docked to install a section")
      return false if @estate.foreign_to?(@starship) && fail!("Must be docked at own estate to install a section")
      return false if !@item.section? && fail!("#{@item.name} is not a valid ship section")
      return false if @estate.count_item(@item) < 1 && fail!("Estate #{@estate.name} has no #{@item.name}")
      true
    end

    def process!
      return false unless processable?
      @starship.install!(@item, @quantity) > 0
    end

    def action_points
      1
    end
  end
end
