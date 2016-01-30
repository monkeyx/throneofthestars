module OrderProcessing
  class LegateOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @army ||= character.current_army
      @estate ||= character.current_estate

      return false if (@army.nil? || @army.legate_id != character.id) && fail!("Not legate of an army")
      true
    end

    def valid_for_character?
      character.legate? && character.current_estate
    end
  end
end
