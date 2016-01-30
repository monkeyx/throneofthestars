module OrderProcessing

  class BaseOrderProcessor
    ORDER_PROCESSORS = {
      # "DUMMY" => {:class_name => 'OrderProcessing::BaseOrderProcessor', :restrictions => []},
      "Buy" => {:class_name => 'OrderProcessing::BuyItemOrder', :restrictions => [:trader?]},
      "Sell" => {:class_name => 'OrderProcessing::SellItemOrder', :restrictions => [:trader?]},
      "Cancel Sale" => {:class_name => 'OrderProcessing::CancelSaleItemOrder', :restrictions => [:trader?]},
      "Teach Skill" => {:class_name => 'OrderProcessing::TeachSkillOrder', :restrictions => [:expert?]},
      "Train Skill" => {:class_name => 'OrderProcessing::TrainSkillOrder', :restrictions => [:employed?]},
      "Appoint Steward" => {:class_name => 'OrderProcessing::AppointStewardOrder', :restrictions => [:lord?]},
      "Appoint Tribune" => {:class_name => 'OrderProcessing::AppointTribuneOrder', :restrictions => [:lord?]},
      "Appoint Chancellor" => {:class_name => 'OrderProcessing::AppointChancellorOrder', :restrictions => [:baron?]},
      "Appoint Emissary" => {:class_name => 'OrderProcessing::AppointEmissaryOrder', :restrictions => [:baron?]},
      "Lead Army" => {:class_name => 'OrderProcessing::LeadArmyOrder', :restrictions => [:adult_male?]},
      "Lead Unit" => {:class_name => 'OrderProcessing::LeadUnitOrder', :restrictions => [:knight?]},
      "Leave Army" => {:class_name => 'OrderProcessing::LeaveArmyOrder', :restrictions => [:with_army?]},
      "Form Army" => {:class_name => 'OrderProcessing::FormArmyOrder', :restrictions => [:lord?]},
      "Heal" => {:class_name => 'OrderProcessing::HealOrder', :restrictions => [:doctor?]},
      "Quit Appointment" => {:class_name => 'OrderProcessing::QuitAppointmentOrder', :restrictions => [:appointed?]},
      "Travel to Estate" => {:class_name => 'OrderProcessing::TravelToEstateOrder', :restrictions => [:adult?]},
      "Construct Building" => {:class_name => 'OrderProcessing::ConstructBuildingOrder', :restrictions => [:management?]},
      "Demolish Building" => {:class_name => 'OrderProcessing::DemolishBuildingOrder', :restrictions => [:management?]},
      "Deliver" => {:class_name => 'OrderProcessing::DeliverOrder', :restrictions => [:management?]},
      "Pickup" => {:class_name => 'OrderProcessing::PickupOrder', :restrictions => [:management?]},
      "Build Starship" => {:class_name => 'OrderProcessing::BuildStarshipOrder', :restrictions => [:management?]},
      "Set Tax Level" => {:class_name => 'OrderProcessing::SetTaxLevelOrder', :restrictions => [:chancellor?]},
      "Set Wage Level" => {:class_name => 'OrderProcessing::SetWageLevelOrder', :restrictions => [:chancellor?]},
      "Sell Workers" => {:class_name => 'OrderProcessing::SellWorkersOrder', :restrictions => [:human_resources?]},
      "Claim Land" => {:class_name => 'OrderProcessing::ClaimLandOrder', :restrictions => [:lord?]},
      "Collect Taxes" => {:class_name => 'OrderProcessing::CollectTaxesOrder', :restrictions => [:lord?]},
      "Gather Resources" => {:class_name => 'OrderProcessing::GatherResourcesOrder', :restrictions => [:lord?]},
      "Produce" => {:class_name => 'OrderProcessing::ProduceItemOrder', :restrictions => [:lord?]},
      "Imprison" => {:class_name => 'OrderProcessing::ImprisonOrder', :restrictions => [:lord?]},
      "Clear Queue" => {:class_name => 'OrderProcessing::ClearProductionOrder', :restrictions => [:steward?]},
      "Add to Queue" => {:class_name => 'OrderProcessing::AddProductionOrder', :restrictions => [:steward?]},
      "Alter Queue" => {:class_name => 'OrderProcessing::AlterProductionOrder', :restrictions => [:steward?]},
      "Create Unit" => {:class_name => 'OrderProcessing::CreateUnitOrder', :restrictions => [:legate?]},
      "Load Unit" => {:class_name => 'OrderProcessing::LoadUnitOrder', :restrictions => [:legate?]},
      "Unload Unit" => {:class_name => 'OrderProcessing::UnloadUnitOrder', :restrictions => [:legate?]},
      "Army Move to Region" => {:class_name => 'OrderProcessing::MoveToRegionOrder', :restrictions => [:legate?]},
      "Army Move to Estate" => {:class_name => 'OrderProcessing::MoveToEstateOrder', :restrictions => [:legate?]},
      "Army Move to Orbit" => {:class_name => 'OrderProcessing::MoveToOrbitOrder', :restrictions => [:legate?]},
      "Give Away Lordship" => {:class_name => 'OrderProcessing::GiveTitleOrder', :restrictions => [:lord?]},
      "Claim Title" => {:class_name => 'OrderProcessing::ClaimTitleOrder', :restrictions => [:baron?]},
      "Ransom Prisoner" => {:class_name => 'OrderProcessing::OfferRansomOrder', :restrictions => [:baron?]},
      "Command Starship" => {:class_name => 'OrderProcessing::CommandShipOrder', :restrictions => [:location_starship?]},
      "Board Starship" => {:class_name => 'OrderProcessing::EmbarkShipOrder', :restrictions => [:current_estate]},
      "Disembark" => {:class_name => 'OrderProcessing::DisembarkShipOrder', :restrictions => [:location_starship?]},
      "Take Off" => {:class_name => 'OrderProcessing::TakeOffOrder', :restrictions => [:captain?]},
      "Dock" => {:class_name => 'OrderProcessing::DockOrder', :restrictions => [:captain?]},
      "Move to World" => {:class_name => 'OrderProcessing::MoveToWorldOrder', :restrictions => [:captain?]},
      "Load Cargo" => {:class_name => 'OrderProcessing::LoadCargoOrder', :restrictions => [:captain?]},
      "Unload Cargo" => {:class_name => 'OrderProcessing::UnloadCargoOrder', :restrictions => [:captain?]},
      "Load Workers" => {:class_name => 'OrderProcessing::LoadWorkerOrder', :restrictions => [:captain?]},
      "Unload Workers" => {:class_name => 'OrderProcessing::UnloadWorkerOrder', :restrictions => [:captain?]},
      "Scan Orbit" => {:class_name => 'OrderProcessing::ScanOrbitOrder', :restrictions => [:captain?]},
      "Salvage" => {:class_name => 'OrderProcessing::SalvageOrder', :restrictions => [:captain?]},
      "Install Section" => {:class_name => 'OrderProcessing::InstallSectionOrder', :restrictions => [:captain?]},
      "Uninstall Section" => {:class_name => 'OrderProcessing::UninstallSectionOrder', :restrictions => [:captain?]},
      "Refit" => {:class_name => 'OrderProcessing::RefitOrder', :restrictions => [:captain?]},
      "Attack Ship" => {:class_name => 'OrderProcessing::AttackShipOrder', :restrictions => [:captain?]},
      "Attack House Ship" => {:class_name => 'OrderProcessing::AttackHouseShipOrder', :restrictions => [:captain?]},
      "Scuttle" => {:class_name => 'OrderProcessing::ScuttleOrder', :restrictions => [:captain?]},
      "Pickup Authorisation" => {:class_name => 'OrderProcessing::GrantRightsOrder', :restrictions => [:management?]},
      "Delivery Authorisation" => {:class_name => 'OrderProcessing::GrantDeliveryRightsOrder', :restrictions => [:management?]},
      "Revoke Authorisation" => {:class_name => 'OrderProcessing::RevokeRightsOrder', :restrictions => [:management?]},
      "Embark Army" => {:class_name => 'OrderProcessing::EmbarkArmyOrder', :restrictions => [:captain?]},
      "Disembark Army" => {:class_name => 'OrderProcessing::DisembarkArmyOrder', :restrictions => [:captain?]},
      "Join Clergy" => {:class_name => 'OrderProcessing::JoinClergyOrder', :restrictions => [:can_join_clergy?]},
      "Pay Tithes" => {:class_name => 'OrderProcessing::PayTithesOrder', :restrictions => [:can_tithe?]},
      "Set Church Budget" => {:class_name => 'OrderProcessing::SetChurchBudgetOrder', :restrictions => [:bishop?]},
      "Hold Tournament" => {:class_name => 'OrderProcessing::HoldTournamentOrder', :restrictions => [:lord?]},
      "Join Tournament" => {:class_name => 'OrderProcessing::JoinTournamentOrder', :restrictions => [:current_estate]},
      "Propose Marriage" => {:class_name => 'OrderProcessing::ProposeMarriageOrder', :restrictions => [:single_male?]},
      "Accept Proposal" => {:class_name => 'OrderProcessing::AcceptMarriageProposalOrder', :restrictions => [:single_female?]},
      "Host Wedding" => {:class_name => 'OrderProcessing::HostWeddingOrder', :restrictions => [:lord?]},
      "Invite to Wedding" => {:class_name => 'OrderProcessing::InviteToWeddingOrder', :restrictions => [:management?]},
      "Add Wedding Items" => {:class_name => 'OrderProcessing::AddWeddingItemsOrder', :restrictions => [:management?]},
      "Demand Justice" => {:class_name => 'OrderProcessing::AccusationOrder', :restrictions => []},
      "Reject Accusation" => {:class_name => 'OrderProcessing::RejectAccusationOrder', :restrictions => []},
      "Trial By Combat" => {:class_name => 'OrderProcessing::TrialByCombatOrder', :restrictions => []},
      "Trial By Court" => {:class_name => 'OrderProcessing::TrialByCourtOrder', :restrictions => []},
      "Trial By Church" => {:class_name => 'OrderProcessing::TrialByChurchOrder', :restrictions => []},
      "Issue Judgement" => {:class_name => 'OrderProcessing::IssueJudgementAgainstOrder', :restrictions => [:pontiff_or_emperor?]},
      "Declare War" => {:class_name => 'OrderProcessing::DeclareWarOrder', :restrictions => [:emissary?]},
      "Offer Truce" => {:class_name => 'OrderProcessing::OfferTruceOrder', :restrictions => [:emissary?]},
      "Offer Peace" => {:class_name => 'OrderProcessing::OfferPeaceOrder', :restrictions => [:emissary?]},
      "Offer Alliance" => {:class_name => 'OrderProcessing::OfferAllianceOrder', :restrictions => [:emissary?]},
      "Offer Allegiance" => {:class_name => 'OrderProcessing::OfferAllegianceOrder', :restrictions => [:emissary?]},
      "Accept Truce" => {:class_name => 'OrderProcessing::AcceptTruceOrder', :restrictions => [:baron?]},
      "Reject Truce" => {:class_name => 'OrderProcessing::RejectTruceOrder', :restrictions => [:baron?]},      
      "Accept Peace" => {:class_name => 'OrderProcessing::AcceptPeaceOrder', :restrictions => [:baron?]},
      "Reject Peace" => {:class_name => 'OrderProcessing::RejectPeaceOrder', :restrictions => [:baron?]},      
      "Accept Alliance" => {:class_name => 'OrderProcessing::AcceptAllianceOrder', :restrictions => [:baron?]},
      "Reject Alliance" => {:class_name => 'OrderProcessing::RejectAllianceOrder', :restrictions => [:baron?]},     
      "Accept Allegiance" => {:class_name => 'OrderProcessing::AcceptAllegianceOrder', :restrictions => [:baron?]},
      "Reject Allegiance" => {:class_name => 'OrderProcessing::RejectAllegianceOrder', :restrictions => [:baron?]},
      "Break Oath" => {:class_name => 'OrderProcessing::BreakOathOrder', :restrictions => [:baron?]},
      "Break Alliance" => {:class_name => 'OrderProcessing::BreakAllianceOrder', :restrictions => [:baron?]},
      "Offer Apprentice" => {:class_name => 'OrderProcessing::OfferApprenticeOrder', :restrictions => [:emissary?]},
      "Accept Apprentice" => {:class_name => 'OrderProcessing::AcceptApprenticeOrder', :restrictions => []},
      "Petition" => {:class_name => 'OrderProcessing::PetitionOrder', :restrictions => [:emissary_or_tribune?]},
      "Spy" => {:class_name => 'OrderProcessing::SpyOrder', :restrictions => [:emissary?]},
      "Sabotage" => {:class_name => 'OrderProcessing::SabotageOrder', :restrictions => [:emissary?]},
      "Assassinate" => {:class_name => 'OrderProcessing::AssassinateOrder', :restrictions => [:emissary?]},
      "Pardon Prisoner" => {:class_name => 'OrderProcessing::PardonPrisonerOrder', :restrictions => [:lord?]},
      "Execute Prisoner" => {:class_name => 'OrderProcessing::ExecutePrisonerOrder', :restrictions => [:lord?]},
      "Repair Hulls" => {:class_name => 'OrderProcessing::RepairHullsOrder', :restrictions => []},
      "Capture Ship" => {:class_name => 'OrderProcessing::CaptureShipOrder', :restrictions => [:captain?]},
      "Attack Armies" => {:class_name => 'OrderProcessing::AttackArmiesOrder', :restrictions => [:gm?]},
      "Assault Estate" => {:class_name => 'OrderProcessing::AssaultEstateOrder', :restrictions => [:gm?]},
      "Break Betrothal" => {:class_name => 'OrderProcessing::BreakBetrothalOrder', :restrictions => [:is_betrothed?]}
    }

    CODES = ORDER_PROCESSORS.keys.sort

    def self.order_processor(code,order)
      return nil unless CODES.include?(code)
      ORDER_PROCESSORS[code][:class_name].constantize.new(order)
    end

    def self.orders_for_character(character)
      valid_codes = CODES.select do |code|
        spec = ORDER_PROCESSORS[code]
        passed = true
        spec[:restrictions].each do |restriction|
          passed = false unless character.send(restriction)
        end
        passed
      end
      valid_codes
    end

    def self.valid_code?(character,code)
      orders_for_character(character).include?(code)
    end

    attr_accessor :order
    
    def initialize(order)
      @order = order
    end

    def code
      self.order.code
    end

    def character
      self.order.character
    end

    def prepare_new_parameters
      # do nothing
    end

    def new_parameter(label, parameter_type,required=false)
      self.order.order_parameters.build(:label => label, :parameter_type => parameter_type, :required => required)
    end

    def processable?
      true
    end

    def calculate_action_points
      # override if necessary
    end

    def process!
      # do nothing
    end

    def variable_points_cost?
      false
    end

    def action_points
      0
    end

    def action_points_on_fail
      0
    end

    def valid_for_character?
      true
    end

    def fail!(reason)
      self.order.failed!(reason)
    end

    def params
      self.order.order_parameters
    end

    def fail_if_required_params_missing!
      failed = false
      params.each do |param|
        if param.required? && param.parameter_value_obj.nil?
          fail!("No #{param.label}")
          failed = true
        end
      end
      failed
    end

    def debug(msg)
      self.character.add_news!('DEBUG',msg)
      Kernel.p msg
    end
  end
end

