module OrderProcessing
  class DeclareWarOrder < EmissaryOrder
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false unless super
      
      return false if @noble_house.ancient? && fail!("May not declare war on an ancient house. You may attack them at will without a declaration.")
      return false if character.noble_house.at_war?(@noble_house) && fail!("Already at war with House #{@noble_house.name}")
      return false if character.noble_house.liege_of?(@noble_house) && fail!("May not declare war on liege")
      return false if character.noble_house.vassal?(@noble_house) && fail!("May not declare war on vassal")
      return false if character.noble_house.cassus_belli(@noble_house).nil? && fail!("No cassus belli to declare war on House #{@noble_house.name}")
      true
    end

    def process!
      return false unless processable?
      return false if character.noble_house.declare_war!(@noble_house) == false
      true
    end

    def action_points
      4
    end

  end
end
