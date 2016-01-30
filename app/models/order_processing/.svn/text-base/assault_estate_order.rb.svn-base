module OrderProcessing
  class AssaultEstateOrder < LegateOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false unless super
      
      @estate ||= @army.current_estate
      
      return false if !character.noble_house.at_war?(@estate.noble_house) && fail!("Must be at war")
      return false if !@army.at_same_estate?(@estate) && fail!("Must be at estate to assault it")
      return false if @army.noble_house_id == @estate.noble_house_id && fail!("Cannot assault your own estate")
      return false if (@army.current_region.nil? || @army.current_region.current_season == Region::WINTER) && fail!("No ground combat in winter")
      true
    end

    def process!
      return false unless processable?
      @army.assault!(@estate)
    end

    def action_points
      4
    end

  end
end
