module OrderProcessing
  class LeaveArmyOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false if fail_if_required_params_missing!

      @army ||= character.location if character.location_army?
      if character.location_unit?
        @unit = character.location
        @army = @unit.army
      end

      @current_estate ||= @army.current_estate
      
      return false if @army.nil? && fail!("Not with an army")
      return false if @current_estate.nil? && fail!("Army not at an estate")
      true
    end

    def process!
      return false unless processable?
      Title.remove_titles!(character,[Title::LEGATE]) if @army.legate_id == character.id
      @unit.update_attributes!(:knight => nil) if @unit && @unit.knight_id == character.id
      character.add_news!("LEAVE_ARMY",@army)
      character.move_to_estate!(@current_estate)
    end

    def action_points
      1
    end

    def valid_for_character?
      character.with_army?
    end
  end
end
