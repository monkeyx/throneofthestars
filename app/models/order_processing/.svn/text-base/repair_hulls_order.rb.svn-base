module OrderProcessing
  class RepairHullsOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Ship", OrderParameter::OWN_STARSHIP,false)
    end

    def processable?
      return false unless super

      @starship ||= params[0].parameter_value_obj
      @starship = nil if @starship && !(character.same_location?(@starship) || character.at_same_estate?(@starship))
      @starship = character.location if character.location_starship?

      return false if @starship.nil? && fail!("Must either specify a starship at the same estate or be onboard one")
      return false if @starship.orbiting? && !@starship.has_nano_repair? && fail!("Must have nano-repair unit to repair in orbit")
      return false if @starship.damage < 1 && fail!("Nothing to repair")
      true
    end

    def process!
      return false unless processable?
      return false unless @starship.repair!(character) > 0 && fail!("Nothing repaired (insufficient ores)")
      true
    end

    def action_points
      4
    end

    def valid_for_character?
      character.location_estate? || character.location_starship?
    end
  end
end
