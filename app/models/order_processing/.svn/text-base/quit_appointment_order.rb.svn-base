module OrderProcessing
  class QuitAppointmentOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
    end

    def processable?
      return false if fail_if_required_params_missing!

      unless @title
        list = Title.belonging_to(character).categories(Title::DOMAIN_TITLES)
        @title = list.first if list.size > 0
        @off_estate = @title && (@title.starship || @title.army || @title.unit)
      end

      return false if @title.nil? && fail!("Not in an appointment")
      true
    end

    def process!
      return false unless processable?
      @title.revoke!
      character.move_to_nearest_estate! if @off_estate
      true
    end

    def action_points
      4
    end

    def valid_for_character?
      character.appointed?
    end
  end
end
