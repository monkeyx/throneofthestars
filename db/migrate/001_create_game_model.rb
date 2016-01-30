class CreateGameModel < ActiveRecord::Migration
	def change
		create_table :games do |t|
	      t.string :current_date
	      t.boolean :updating, :default => false
	      t.boolean :dispatching, :default => false
	      t.timestamps
	    end
	    create_table :players do |t|
	      t.string :guid
	      t.string :name
	      t.string :username, :null => false
	      t.string :email, :null => false
	      t.string :crypted_password, :null => false
	      t.string :password_salt, :null => false
	      t.string :persistence_token, :null => false
	      t.string :perishable_token, :string, :default => "", :null => false 
	      t.integer   :login_count,         :null => false, :default => 0
	      t.integer   :failed_login_count,  :null => false, :default => 0
	      t.datetime  :last_request_at
	      t.datetime  :current_login_at
	      t.datetime  :last_login_at
	      t.string    :current_login_ip
	      t.string    :last_login_ip
	      t.boolean :gm, :default => false
	      t.integer :credits, :default => 30
	      t.boolean :unlimited_credits, :default => false
	      t.boolean :active, :default => true
	      t.boolean :confirmed, :default => false
	      t.string :confirm_code
	      t.boolean :email_house_news, :default => true
	      t.boolean :email_newsletter, :default => true
	      t.boolean :email_messages, :default => true
	      t.datetime :last_house_news
	      t.timestamps
	    end
	    add_index :players, :username
	    add_index :players, :email
	    add_index :players, :active
	    add_index :players, :gm
	    add_index :players, :confirm_code
	    create_table :worlds do |t|
	      t.string :name
	      t.integer :distance
	      t.integer :quadrant
	      t.integer :rotation
	      t.string :last_imperial_tribute
	      t.string :last_rotation
	      t.string :last_tribute
	      t.float :church_funds, :default => 0
	      t.integer :duke_id
	      t.integer :archbishop_id
	      t.timestamps
	    end
	    add_index :worlds, :name
	    create_table :world_projects do |t|
	      t.integer :world_id
	      t.string :category
	      t.string :build_date

	      t.timestamps
	    end
	    add_index :world_projects, :world_id
	    add_index :world_projects, :category
	    create_table :items do |t|
	      t.string :name
	      t.integer :mass
	      t.string :category
	      t.string :description
	      t.string :project_required, :default => ''
	      # resources
	      t.integer :rich_yield, :default => 0
	      t.integer :normal_yield, :default => 0
	      t.integer :poor_yield, :default => 0
	      t.string :trade_good_type, :default => ''
	      t.integer :source_world_id
	      # workers
	      t.string :worker_type, :default => ''
	      # ground combat
	      t.string :air_supremacy, :default => ''
	      t.string :strategic_to_hit, :default => ""
	      t.string :strategic_damage, :default => ""
	      t.string :tactical_to_hit, :default => ""
	      t.string :tactical_damage, :default => ""
	      t.integer :hit_points, :default => 0
	      t.string :ground_armour_save, :default => ""
	      # ground movement
	      t.string :movement, :default => ''
	      t.integer :transport_capacity, :default => 0
	      t.boolean :one_use
	      t.boolean :immobile, :default => false
	      # space combat
	      t.string :weapon_speed, :default => ''
	      t.boolean :torpedo_launcher, :default => false
	      t.boolean :missile_launcher, :default => false
	      t.boolean :drone_launcher, :default => false
	      t.string :accuracy, :default => ''
	      t.string :damage, :default => ''
	      t.string :shot_down, :default => ''
	      t.integer :internal_damage, :default => 0
	      t.integer :lifeform_damage, :default => 0
	      t.boolean :reduce_speed, :default => false
	      t.string :building_bombardment, :default => ''
	      t.string :item_bombardment, :default => ''
	      # ship hulls
	      t.float :armour_slots, :default => 0
	      t.integer :command_slots, :default => 0
	      t.float :mission_slots, :default => 0
	      t.float :engine_slots, :default => 0
	      t.float :utility_slots, :default => 0
	      t.float :primary_slots, :default => 0
	      t.float :spinal_slots, :default => 0
	      t.integer :hull_points, :default => 0
	      # ship armour
	      t.string :ship_armour_light, :default => ''
	      t.string :ship_armour_normal, :default => ''
	      t.string :ship_armour_heavy, :default => ''
	      # ship shields
	      t.string :ship_shield_low, :default => ''
	      t.string :ship_shield_medium, :default => ''
	      t.string :ship_shield_high, :default => ''
	      # sensors / jammers
	      t.string :sensor_power, :default => ''
	      t.string :jammer_power_full, :default => ""
	      t.string :jammer_power_partial, :default => ""
	      # ship special
	      t.integer :accuracy_modifier, :default => 0
	      t.boolean :cloak, :default => false
	      t.boolean :escape_pod, :default => false
	      t.boolean :bridge, :default => false
	      t.boolean :nano_repair, :default => false
	      t.boolean :orbital_trade, :default => false
	      # ship cargo
	      t.integer :ammo_capacity, :default => 0
	      t.integer :worker_capacity, :default => 0
	      t.integer :troop_capacity, :default => 0
	      t.integer :ore_capacity, :default => 0
	      t.integer :cargo_capacity, :default => 0
	      # ship engines
	      t.float :impulse_speed, :default => 0
	      t.float :impulse_modifier, :default => 0
	      t.float :thrust_speed, :default => 0
	      t.float :dodge_speed, :default => 0
	      t.timestamps
	    end
	    add_index :items, :name
	    add_index :items, :category
	    add_index :items, :trade_good_type
	    add_index :items, :source_world_id
	    add_index :items, :worker_type
	    create_table :item_bundles do |t|
	      t.string :owner_type
	      t.integer :owner_id
	      t.integer :item_id
	      t.integer :quantity

	      t.timestamps
	    end
	    add_index :item_bundles, :owner_type
	    add_index :item_bundles, :owner_id
	    add_index :item_bundles, :item_id
	    create_table :regions do |t|
	      t.string :name
	      t.string :hemisphere, :default => ''
	      t.integer :total_lands, :default => 0
	      t.integer :unclaimed_lands, :default => 0
	      t.integer :infrastructure, :default => 0
	      t.string :last_tribute, :default => ''
	      t.integer :world_id
	      t.float :church_funds, :default => 0
	      t.float :alms, :default => 100
	      t.float :education, :default => 0
	      t.float :faith_projects, :default => 0
	      t.integer :earl_id
	      t.integer :bishop_id
	      t.timestamps
	    end
	    add_index :regions, :world_id
	    add_index :regions, :name
	    add_index :regions, :unclaimed_lands
	    add_index :regions, :total_lands
	    create_table :resources do |t|
	      t.integer :region_id
	      t.integer :item_id
	      t.string :yield_category, :default => 'Normal'
	      t.timestamps
	    end
	    add_index :resources, :region_id
	    add_index :resources, :item_id
	    add_index :resources, :yield_category
	    create_table :noble_houses do |t|
	      t.integer :player_id
	      t.integer :baron_id
	      t.integer :chancellor_id
	      t.string :name
	      t.float :wealth, :default => 0
	      t.float :honour, :default => 0
	      t.float :glory, :default => 0
	      t.float :piety, :default => 0
	      t.string :formed_date
	      t.boolean :ancient, :default => false
	      t.boolean :active, :default => false
	      t.timestamps
	    end
	    add_index :noble_houses, :player_id
	    add_index :noble_houses, :ancient
	    add_index :noble_houses, :active
	    create_table :market_items do |t|
	      t.integer :noble_house_id
	      t.integer :item_id
	      t.integer :world_id
	      t.integer :quantity, :default => 0
	      t.float :price
	      t.string :listed_date
	      t.timestamps
	    end
	    add_index :market_items, :noble_house_id
	    add_index :market_items, :item_id
	    add_index :market_items, :world_id
	    add_index :market_items, :price
	    create_table :diplomatic_relations do |t|
	      t.integer :noble_house_id
	      t.integer :target_id
	      t.string :cause, :default => ''
	      t.integer :proposed_by_id
	      t.string :proposal_date
	      t.integer :response_by_id
	      t.string :response_date
	      t.string :category, :default => 'Peace'
	      t.string :established_date
	      t.boolean :accepted
	      t.boolean :forced
	      t.timestamps
	    end
	    add_index :diplomatic_relations, :noble_house_id
	    add_index :diplomatic_relations, :target_id
	    add_index :diplomatic_relations, :category
	    add_index :diplomatic_relations, :accepted
	    add_index :diplomatic_relations, :forced
	    create_table :diplomatic_tokens do |t|
	      t.integer :diplomatic_relation_id
	      t.integer :estate_id
	      t.float :sovereigns, :default => 0
	      t.boolean :oath, :default => false
	      t.integer :lands, :default => 0

	      t.timestamps
	    end
	    add_index :diplomatic_tokens, :diplomatic_relation_id
	    add_index :diplomatic_tokens, :estate_id
	    create_table :prisoners do |t|
	      t.integer :noble_house_id
	      t.integer :estate_id
	      t.integer :character_id
	      t.string :captured_date

	      t.timestamps
	    end
	    add_index :prisoners, :noble_house_id
	    add_index :prisoners, :estate_id
	    add_index :prisoners, :character_id
	    create_table :ransoms do |t|
	      t.integer :character_id
	      t.string :offered_date
	      t.integer :prisoner_id
	      t.float :ransom, :default => 0
	      t.timestamps
	    end
	    add_index :ransoms, :character_id
	    add_index :ransoms, :prisoner_id
	    create_table :messages do |t|
	      t.string :guid
	      t.integer :character_id
	      t.integer :from_id
	      t.string :sent_date
	      t.integer :reply_to_id
	      t.text :subject
	      t.text :content
	      t.text :formatted_content
	      t.integer :sovereigns, :default => 0
	      t.boolean :archived, :default => false
	      t.boolean :reported, :default => false
	      t.timestamps
	    end
	    add_index :messages, :character_id
	    add_index :messages, :from_id
	    add_index :messages, :reply_to_id
	    create_table :news do |t|
	      t.integer :noble_house_id
	      t.string :source_type
	      t.integer :source_id
	      t.string :target_type
	      t.integer :target_id
	      t.string :news_date
	      t.string :code, :default => ''
	      t.boolean :church, :default => false
	      t.boolean :empire, :default => false
	      t.text :description
	      t.boolean :system_error
	      t.timestamps
	    end
	    add_index :news, :noble_house_id
	    add_index :news, :source_type
	    add_index :news, :source_id
	    add_index :news, :code
	    add_index :news, :target_type
	    add_index :news, :target_id
	    add_index :news, :news_date
	    add_index :news, :church
	    add_index :news, :empire
	    create_table :characters do |t|
	      t.string :guid
	      t.string :name
	      t.string :category, :default => 'Minor'
	      t.integer :noble_house_id
	      t.integer :father_id
	      t.integer :mother_id
	      t.integer :betrothed_id
	      t.integer :spouse_id
	      t.string :gender, :default => 'Male'
	      t.string :birth_date
	      t.boolean :dead, :default => false
	      t.string :death_date
	      t.integer :birth_place_id
	      t.integer :health, :default => 100
	      t.integer :action_points, :default => 0
	      t.float :action_points_modifier, :default => 0
	      t.string :life_expectancy
	      t.float :intimidation, :default => 0
	      t.float :influence, :default => 0
	      t.float :honour_modifier, :default => 0
	      t.float :glory_modifier, :default => 0
	      t.float :piety_modifier, :default => 0
	      t.string :location_type
	      t.integer :location_id
	      t.float :wealth, :default => 0
	      t.integer :loyalty, :default => 100
	      t.float :pension, :default => 0
	      t.timestamps
	    end
	    add_index :characters, :guid
	    add_index :characters, :category
	    add_index :characters, :noble_house_id
	    add_index :characters, :father_id
	    add_index :characters, :mother_id
	    add_index :characters, :dead
	    add_index :characters, :location_type
	    add_index :characters, :location_id
	    create_table :skills do |t|
	      t.integer :character_id
	      t.string :category, :allow_nil => false
	      t.string :obtained_date
	      t.boolean :training
	      t.string :training_start_date
	      t.integer :rank, :default => 0
	      t.timestamps
	    end
	    add_index :skills, :character_id
	    add_index :skills, :category
	    add_index :skills, :training
	    create_table :traits do |t|
	      t.integer :character_id
	      t.string :category
	      t.string :acquired_date
	      t.timestamps
	    end
	    add_index :traits, :character_id
	    add_index :traits, :category
	    create_table :marriage_proposals do |t|
	      t.integer :character_id
	      t.integer :target_id
	      t.float :dowry, :default => 0
	      t.string :proposal_date
	      t.timestamps
	    end
	    add_index :marriage_proposals, :character_id
	    add_index :marriage_proposals, :target_id
	    create_table :estates do |t|
	      t.string :guid
	      t.integer :region_id
	      t.integer :noble_house_id
	      t.string :name, :default => ''
	      t.string :build_date
	      t.string :captured_date
	      t.string :destroyed_date
	      t.integer :lord_id
	      t.integer :steward_id
	      t.integer :tribune_id
	      t.integer :deacon_id
	      t.integer :lands, :default => 0
	      t.float :taxes, :default => 0.0
	      t.float :slave_wages, :default => 0.0
	      t.float :freemen_wages, :default => 0.0
	      t.float :artisan_wages, :default => 0.0
	      t.timestamps
	    end
	    add_index :estates, :guid
	    add_index :estates, :region_id
	    add_index :estates, :noble_house_id
	    create_table :building_types do |t|
	      t.string :category
	      t.string :worker_type, :default => ''
	      t.integer :workers_needed, :default => 0
	      t.integer :item_produced_id
	      t.string :trade_good_type, :default => ''
	      t.string :recruitment_type, :default => ''
	      t.integer :item_produced_quantity, :default => 0
	      t.timestamps
	    end
	    add_index :building_types, :category
	    add_index :building_types, :worker_type
	    add_index :building_types, :item_produced_id
	    add_index :building_types, :trade_good_type
	    add_index :building_types, :recruitment_type
	    create_table :buildings do |t|
	      t.integer :estate_id
	      t.integer :building_type_id
	      t.integer :level, :default => 0
	      t.string :build_date
	      t.string :upgraded_date
	      t.integer :capacity_used, :default => 0
	      t.timestamps
	    end
	    add_index :buildings, :estate_id
	    add_index :buildings, :building_type_id
	    create_table :populations do |t|
	      t.integer :estate_id
	      t.string :category
	      t.integer :quantity, :default => 0
	      t.float :morale, :default => 1.0
	      t.float :wealth, :default => 0

	      t.timestamps
	    end
	    add_index :populations, :estate_id
	    add_index :populations, :category
	    create_table :authorisations do |t|
	      t.integer :estate_id
	      t.integer :noble_house_id
	      t.integer :item_id
	      t.integer :quantity, :default => 0
	      t.string :issued_date
	      t.boolean :delivery, :default => false
	      t.timestamps
	    end
	    add_index :authorisations, :estate_id
	    add_index :authorisations, :noble_house_id
	    add_index :authorisations, :item_id
	    create_table :production_queues do |t|
	      t.integer :estate_id
	      t.integer :position, :default => -1
	      t.integer :item_id
	      t.integer :quantity, :default => 1
	      t.integer :capacity_stored, :default => 0
	      t.timestamps
	    end
	    add_index :production_queues, :estate_id
	    add_index :production_queues, :position
	    add_index :production_queues, :item_id
	    create_table :weddings do |t|
	      t.integer :estate_id
	      t.integer :groom_id
	      t.integer :bride_id
	      t.string :event_date
	      t.timestamps
	    end
	    add_index :weddings, :estate_id
	    add_index :weddings, :groom_id
	    add_index :weddings, :bride_id
	    add_index :weddings, :event_date
	    create_table :wedding_invites do |t|
	      t.integer :wedding_id
	      t.integer :character_id
	      t.string :sent_date
	      t.boolean :attended
	      t.timestamps
	    end
	    add_index :wedding_invites, :wedding_id
	    add_index :wedding_invites, :character_id
	    add_index :wedding_invites, :attended
	    create_table :tournaments do |t|
	      t.integer :estate_id
	      t.integer :winner_id
	      t.integer :runner_up1_id
	      t.integer :runner_up2_id
	      t.string :event_date
	      t.float :prize
	      t.timestamps
	    end
	    add_index :tournaments, :estate_id
	    add_index :tournaments, :event_date
	    create_table :tournament_entrants do |t|
	      t.integer :tournament_id
	      t.integer :character_id
	      t.string :joined_date
	      t.timestamps
	    end
	    add_index :tournament_entrants, :tournament_id
	    add_index :tournament_entrants, :character_id
	    create_table :starship_types do |t|
	      t.string :name
	      t.integer :hull_type_id
	      t.integer :hull_size, :default => 0
	      t.string :project_required, :default => ''
	      t.timestamps
	    end
	    add_index :starship_types, :name
	    add_index :starship_types, :hull_type_id
	    add_index :starship_types, :project_required
	    create_table :starships do |t|
	      t.string :guid
	      t.string :name
	      t.integer :noble_house_id
	      t.integer :starship_type_id
	      t.integer :starship_configuration_id
	      t.string :built_date
	      t.integer :built_by_id
	      t.integer :built_location_id
	      t.integer :hulls_assembled, :default => 0
	      t.string :location_type
	      t.integer :location_id
	      t.integer :captain_id
	      t.integer :hull_points, :default => 0
	      t.string :destroyed_date
	      t.timestamps
	    end
	    add_index :starships, :guid
	    add_index :starships, :noble_house_id
	    add_index :starships, :starship_type_id
	    add_index :starships, :location_type
	    add_index :starships, :location_id
	    create_table :sections do |t|
	      t.integer :starship_id
	      t.integer :item_id
	      t.integer :quantity, :default => 0
	      t.timestamps
	    end
	    add_index :sections, :starship_id
	    add_index :sections, :item_id
	    create_table :crews do |t|
	      t.integer :starship_id
	      t.integer :character_id
	      t.boolean :lieutenant
	      t.timestamps
	    end
	    add_index :crews, :starship_id
	    add_index :crews, :character_id
	    add_index :crews, :lieutenant
	    create_table :scans do |t|
	      t.integer :starship_id
	      t.integer :world_id
	      t.integer :target_id
	      t.string :scan_date
	      t.timestamps
	    end
	    add_index :scans, :starship_id
	    add_index :scans, :world_id
	    add_index :scans, :target_id
	    add_index :scans, :scan_date
	    create_table :armies do |t|
	      t.string :guid
	      t.integer :noble_house_id
	      t.string :name
	      t.string :location_type
	      t.integer :location_id
	      t.integer :legate_id
	      t.float :morale, :default => 100.0
	      t.timestamps
	    end
	    add_index :armies, :guid
	    add_index :armies, :noble_house_id
	    add_index :armies, :location_type
	    add_index :armies, :location_id
	    create_table :units do |t|
	      t.string :name
	      t.integer :army_id
	      t.integer :knight_id
	      t.timestamps
	    end
	    add_index :units, :army_id
	    create_table :apprentices do |t|
	      t.integer :novice_id
	      t.integer :character_id
	      t.boolean :accepted, :default => false
	      t.timestamps
	    end
	    add_index :apprentices, :novice_id
	    add_index :apprentices, :character_id
	    create_table :titles do |t|
	      t.integer :character_id
	      t.string :obtained_date
	      t.string :category
	      t.string :sub_category
	      t.integer :noble_house_id
	      t.integer :estate_id
	      t.integer :starship_id
	      t.integer :army_id
	      t.integer :unit_id
	      t.integer :region_id
	      t.integer :world_id
	      t.timestamps
	    end
	    add_index :titles, :character_id
	    add_index :titles, :sub_category
	    add_index :titles, :category
	    add_index :titles, :noble_house_id
	    add_index :titles, :estate_id
	    add_index :titles, :starship_id
	    add_index :titles, :army_id
	    add_index :titles, :unit_id
	    add_index :titles, :region_id
	    add_index :titles, :world_id
	    create_table :accusations do |t|
	      t.integer :character_id
	      t.integer :accused_id
	      t.string :accusation_date
	      t.string :response, :default => ''
	      t.string :response_date
	      t.string :combat_type
	      t.integer :judged_against_id
	      t.timestamps
	    end
	    add_index :accusations, :character_id
	    add_index :accusations, :accused_id
	    create_table :laws do |t|
	      t.string :category
	      t.string :enacted_date
	      t.integer :enacted_by_id
	      t.string :revoked_date
	      t.integer :revoked_by_id
	      t.integer :refused_by_id
	      t.string :target_type
	      t.integer :target_id
	      t.boolean :active, :default => false
	      t.timestamps
	    end
	    add_index :laws, :category
	    add_index :laws, :active
	    add_index :laws, :target_type
	    add_index :laws, :target_id
	    create_table :orders do |t|
	      t.integer :character_id
	      t.string :code
	      t.string :special_instruction
	      t.string :signal, :default => ''
	      t.boolean :finished, :default => false
	      t.string :run_at
	      t.boolean :success, :default => false
	      t.text :error_msg
	      t.boolean :run_chronum, :default => false
	      t.timestamps
	    end
	    create_table :order_parameters do |t|
	      t.integer :order_id
	      t.string :label
	      t.string :parameter_type
	      t.string :parameter_value
	      t.boolean :required
	      t.timestamps
	    end
	    add_index :orders, :character_id
	    add_index :orders, :code
	    add_index :orders, :finished
	    add_index :orders, :success
	    add_index :orders, :run_chronum
	    add_index :order_parameters, :order_id
	    add_index :order_parameters,:label
	    create_table :starship_configurations do |t|
	      t.integer :starship_type_id
	      t.integer :noble_house_id
	      t.string :name
	      t.timestamps
	    end
	    add_index :starship_configurations, :starship_type_id
	    add_index :starship_configurations, :noble_house_id
	    create_table :starship_configuration_items do |t|
	      t.integer :starship_configuration_id
	      t.integer :item_id
	      t.integer :quantity, :default => 0
	      t.timestamps
	    end
	    add_index :starship_configuration_items, :starship_configuration_id
	    add_index :starship_configuration_items, :item_id
	    create_table :space_battles do |t|
	      t.integer :attacker_id
	      t.integer :defender_id
	      t.string :location_type
	      t.integer :location_id
	      t.string :battle_date
	      t.text :report
	      t.string :battle_status
	      t.timestamps
	    end
	    add_index :space_battles, :attacker_id
	    add_index :space_battles, :defender_id
	    add_index :space_battles, :location_type
	    add_index :space_battles, :location_id
	    create_table :ground_battles do |t|
	      t.string :attacker_type
	      t.integer :attacker_id
	      t.string :defender_type
	      t.integer :defender_id
	      t.string :location_type
	      t.integer :location_id
	      t.string :battle_date
	      t.text :report
	      t.string :battle_status

	      t.timestamps
	    end
	    add_index :ground_battles, :attacker_type
	    add_index :ground_battles, :attacker_id
	    add_index :ground_battles, :defender_type
	    add_index :ground_battles, :defender_id
	    add_index :ground_battles, :location_type
	    add_index :ground_battles, :location_id
	    create_table :sessions do |t|
	      t.string :session_id, :null => false
	      t.text :data
	      t.timestamps
	    end
	    add_index :sessions, :session_id
	    add_index :sessions, :updated_at
	end
end