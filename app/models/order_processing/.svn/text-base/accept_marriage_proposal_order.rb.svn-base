module OrderProcessing
  class AcceptMarriageProposalOrder < BaseOrderProcessor
    def initialize(order)
      super(order)
    end

    def prepare_new_parameters
      new_parameter("Noble House", OrderParameter::NOBLE_HOUSE,true)
      new_parameter("Potential Husband", OrderParameter::SINGLE_MALE,true)
    end

    def processable?
      return false if fail_if_required_params_missing!
      
      @potential_husband ||= params[1].parameter_value_obj
      proposals = MarriageProposal.from(@potential_husband).to(character)
      @marriage_proposal ||= proposals.first if proposals.size > 0

      return false if !@marriage_proposal && fail!("No proposal to accept")
      return false if !@potential_husband.single_male? && fail!("Potential husband must be a single male")
      true
    end

    def process!
      return false unless processable?
      @marriage_proposal.accept!
    end

    def action_points
      1
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      character.single_female?
    end
  end
end
