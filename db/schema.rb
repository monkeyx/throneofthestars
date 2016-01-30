# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 10) do

  create_table "accusations", :force => true do |t|
    t.integer  "character_id"
    t.integer  "accused_id"
    t.string   "accusation_date"
    t.string   "response",          :default => ""
    t.string   "response_date"
    t.string   "combat_type"
    t.integer  "judged_against_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "accusations", ["accused_id"], :name => "index_accusations_on_accused_id"
  add_index "accusations", ["character_id"], :name => "index_accusations_on_character_id"

  create_table "apprentices", :force => true do |t|
    t.integer  "novice_id"
    t.integer  "character_id"
    t.boolean  "accepted",     :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "apprentices", ["character_id"], :name => "index_apprentices_on_character_id"
  add_index "apprentices", ["novice_id"], :name => "index_apprentices_on_novice_id"

  create_table "armies", :force => true do |t|
    t.string   "guid"
    t.integer  "noble_house_id"
    t.string   "name"
    t.string   "location_type"
    t.integer  "location_id"
    t.integer  "legate_id"
    t.float    "morale",         :default => 100.0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "armies", ["guid"], :name => "index_armies_on_guid"
  add_index "armies", ["location_id"], :name => "index_armies_on_location_id"
  add_index "armies", ["location_type"], :name => "index_armies_on_location_type"
  add_index "armies", ["noble_house_id"], :name => "index_armies_on_noble_house_id"

  create_table "authorisations", :force => true do |t|
    t.integer  "estate_id"
    t.integer  "noble_house_id"
    t.integer  "item_id"
    t.integer  "quantity",       :default => 0
    t.string   "issued_date"
    t.boolean  "delivery",       :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "authorisations", ["estate_id"], :name => "index_authorisations_on_estate_id"
  add_index "authorisations", ["item_id"], :name => "index_authorisations_on_item_id"
  add_index "authorisations", ["noble_house_id"], :name => "index_authorisations_on_noble_house_id"

  create_table "building_types", :force => true do |t|
    t.string   "category"
    t.string   "worker_type",            :default => ""
    t.integer  "workers_needed",         :default => 0
    t.integer  "item_produced_id"
    t.string   "trade_good_type",        :default => ""
    t.string   "recruitment_type",       :default => ""
    t.integer  "item_produced_quantity", :default => 0
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "building_types", ["category"], :name => "index_building_types_on_category"
  add_index "building_types", ["item_produced_id"], :name => "index_building_types_on_item_produced_id"
  add_index "building_types", ["recruitment_type"], :name => "index_building_types_on_recruitment_type"
  add_index "building_types", ["trade_good_type"], :name => "index_building_types_on_trade_good_type"
  add_index "building_types", ["worker_type"], :name => "index_building_types_on_worker_type"

  create_table "buildings", :force => true do |t|
    t.integer  "estate_id"
    t.integer  "building_type_id"
    t.integer  "level",            :default => 0
    t.string   "build_date"
    t.string   "upgraded_date"
    t.integer  "capacity_used",    :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "buildings", ["building_type_id"], :name => "index_buildings_on_building_type_id"
  add_index "buildings", ["estate_id"], :name => "index_buildings_on_estate_id"

  create_table "characters", :force => true do |t|
    t.string   "guid"
    t.string   "name"
    t.string   "category",               :default => "Minor"
    t.integer  "noble_house_id"
    t.integer  "father_id"
    t.integer  "mother_id"
    t.integer  "betrothed_id"
    t.integer  "spouse_id"
    t.string   "gender",                 :default => "Male"
    t.string   "birth_date"
    t.boolean  "dead",                   :default => false
    t.string   "death_date"
    t.integer  "birth_place_id"
    t.integer  "health",                 :default => 100
    t.integer  "action_points",          :default => 0
    t.float    "action_points_modifier", :default => 0.0
    t.string   "life_expectancy"
    t.float    "intimidation",           :default => 0.0
    t.float    "influence",              :default => 0.0
    t.float    "honour_modifier",        :default => 0.0
    t.float    "glory_modifier",         :default => 0.0
    t.float    "piety_modifier",         :default => 0.0
    t.string   "location_type"
    t.integer  "location_id"
    t.float    "wealth",                 :default => 0.0
    t.integer  "loyalty",                :default => 100
    t.float    "pension",                :default => 0.0
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "characters", ["category"], :name => "index_characters_on_category"
  add_index "characters", ["dead"], :name => "index_characters_on_dead"
  add_index "characters", ["father_id"], :name => "index_characters_on_father_id"
  add_index "characters", ["guid"], :name => "index_characters_on_guid"
  add_index "characters", ["location_id"], :name => "index_characters_on_location_id"
  add_index "characters", ["location_type"], :name => "index_characters_on_location_type"
  add_index "characters", ["mother_id"], :name => "index_characters_on_mother_id"
  add_index "characters", ["noble_house_id"], :name => "index_characters_on_noble_house_id"

  create_table "crews", :force => true do |t|
    t.integer  "starship_id"
    t.integer  "character_id"
    t.boolean  "lieutenant"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "crews", ["character_id"], :name => "index_crews_on_character_id"
  add_index "crews", ["lieutenant"], :name => "index_crews_on_lieutenant"
  add_index "crews", ["starship_id"], :name => "index_crews_on_starship_id"

  create_table "diplomatic_relations", :force => true do |t|
    t.integer  "noble_house_id"
    t.integer  "target_id"
    t.string   "cause",            :default => ""
    t.integer  "proposed_by_id"
    t.string   "proposal_date"
    t.integer  "response_by_id"
    t.string   "response_date"
    t.string   "category",         :default => "Peace"
    t.string   "established_date"
    t.boolean  "accepted"
    t.boolean  "forced"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "diplomatic_relations", ["accepted"], :name => "index_diplomatic_relations_on_accepted"
  add_index "diplomatic_relations", ["category"], :name => "index_diplomatic_relations_on_category"
  add_index "diplomatic_relations", ["forced"], :name => "index_diplomatic_relations_on_forced"
  add_index "diplomatic_relations", ["noble_house_id"], :name => "index_diplomatic_relations_on_noble_house_id"
  add_index "diplomatic_relations", ["target_id"], :name => "index_diplomatic_relations_on_target_id"

  create_table "diplomatic_tokens", :force => true do |t|
    t.integer  "diplomatic_relation_id"
    t.integer  "estate_id"
    t.float    "sovereigns",             :default => 0.0
    t.boolean  "oath",                   :default => false
    t.integer  "lands",                  :default => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "diplomatic_tokens", ["diplomatic_relation_id"], :name => "index_diplomatic_tokens_on_diplomatic_relation_id"
  add_index "diplomatic_tokens", ["estate_id"], :name => "index_diplomatic_tokens_on_estate_id"

  create_table "estates", :force => true do |t|
    t.string   "guid"
    t.integer  "region_id"
    t.integer  "noble_house_id"
    t.string   "name",           :default => ""
    t.string   "build_date"
    t.string   "captured_date"
    t.string   "destroyed_date"
    t.integer  "lord_id"
    t.integer  "steward_id"
    t.integer  "tribune_id"
    t.integer  "deacon_id"
    t.integer  "lands",          :default => 0
    t.float    "taxes",          :default => 0.0
    t.float    "slave_wages",    :default => 0.0
    t.float    "freemen_wages",  :default => 0.0
    t.float    "artisan_wages",  :default => 0.0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "estates", ["guid"], :name => "index_estates_on_guid"
  add_index "estates", ["noble_house_id"], :name => "index_estates_on_noble_house_id"
  add_index "estates", ["region_id"], :name => "index_estates_on_region_id"

  create_table "games", :force => true do |t|
    t.string   "current_date"
    t.boolean  "updating",     :default => false
    t.boolean  "dispatching",  :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "ground_battles", :force => true do |t|
    t.string   "attacker_type"
    t.integer  "attacker_id"
    t.string   "defender_type"
    t.integer  "defender_id"
    t.string   "location_type"
    t.integer  "location_id"
    t.string   "battle_date"
    t.text     "report"
    t.string   "battle_status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "ground_battles", ["attacker_id"], :name => "index_ground_battles_on_attacker_id"
  add_index "ground_battles", ["attacker_type"], :name => "index_ground_battles_on_attacker_type"
  add_index "ground_battles", ["defender_id"], :name => "index_ground_battles_on_defender_id"
  add_index "ground_battles", ["defender_type"], :name => "index_ground_battles_on_defender_type"
  add_index "ground_battles", ["location_id"], :name => "index_ground_battles_on_location_id"
  add_index "ground_battles", ["location_type"], :name => "index_ground_battles_on_location_type"

  create_table "item_bundles", :force => true do |t|
    t.string   "owner_type"
    t.integer  "owner_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "item_bundles", ["item_id"], :name => "index_item_bundles_on_item_id"
  add_index "item_bundles", ["owner_id"], :name => "index_item_bundles_on_owner_id"
  add_index "item_bundles", ["owner_type"], :name => "index_item_bundles_on_owner_type"

  create_table "items", :force => true do |t|
    t.string   "name"
    t.integer  "mass"
    t.string   "category"
    t.string   "description"
    t.string   "project_required",     :default => ""
    t.integer  "rich_yield",           :default => 0
    t.integer  "normal_yield",         :default => 0
    t.integer  "poor_yield",           :default => 0
    t.string   "trade_good_type",      :default => ""
    t.integer  "source_world_id"
    t.string   "worker_type",          :default => ""
    t.string   "air_supremacy",        :default => ""
    t.string   "strategic_to_hit",     :default => ""
    t.string   "strategic_damage",     :default => ""
    t.string   "tactical_to_hit",      :default => ""
    t.string   "tactical_damage",      :default => ""
    t.integer  "hit_points",           :default => 0
    t.string   "ground_armour_save",   :default => ""
    t.string   "movement",             :default => ""
    t.integer  "transport_capacity",   :default => 0
    t.boolean  "one_use"
    t.boolean  "immobile",             :default => false
    t.string   "weapon_speed",         :default => ""
    t.boolean  "torpedo_launcher",     :default => false
    t.boolean  "missile_launcher",     :default => false
    t.boolean  "drone_launcher",       :default => false
    t.string   "accuracy",             :default => ""
    t.string   "damage",               :default => ""
    t.string   "shot_down",            :default => ""
    t.integer  "internal_damage",      :default => 0
    t.integer  "lifeform_damage",      :default => 0
    t.boolean  "reduce_speed",         :default => false
    t.string   "building_bombardment", :default => ""
    t.string   "item_bombardment",     :default => ""
    t.float    "armour_slots",         :default => 0.0
    t.integer  "command_slots",        :default => 0
    t.float    "mission_slots",        :default => 0.0
    t.float    "engine_slots",         :default => 0.0
    t.float    "utility_slots",        :default => 0.0
    t.float    "primary_slots",        :default => 0.0
    t.float    "spinal_slots",         :default => 0.0
    t.integer  "hull_points",          :default => 0
    t.string   "ship_armour_light",    :default => ""
    t.string   "ship_armour_normal",   :default => ""
    t.string   "ship_armour_heavy",    :default => ""
    t.string   "ship_shield_low",      :default => ""
    t.string   "ship_shield_medium",   :default => ""
    t.string   "ship_shield_high",     :default => ""
    t.string   "sensor_power",         :default => ""
    t.string   "jammer_power_full",    :default => ""
    t.string   "jammer_power_partial", :default => ""
    t.integer  "accuracy_modifier",    :default => 0
    t.boolean  "cloak",                :default => false
    t.boolean  "escape_pod",           :default => false
    t.boolean  "bridge",               :default => false
    t.boolean  "nano_repair",          :default => false
    t.boolean  "orbital_trade",        :default => false
    t.integer  "ammo_capacity",        :default => 0
    t.integer  "worker_capacity",      :default => 0
    t.integer  "troop_capacity",       :default => 0
    t.integer  "ore_capacity",         :default => 0
    t.integer  "cargo_capacity",       :default => 0
    t.float    "impulse_speed",        :default => 0.0
    t.float    "impulse_modifier",     :default => 0.0
    t.float    "thrust_speed",         :default => 0.0
    t.float    "dodge_speed",          :default => 0.0
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "items", ["category"], :name => "index_items_on_category"
  add_index "items", ["name"], :name => "index_items_on_name"
  add_index "items", ["source_world_id"], :name => "index_items_on_source_world_id"
  add_index "items", ["trade_good_type"], :name => "index_items_on_trade_good_type"
  add_index "items", ["worker_type"], :name => "index_items_on_worker_type"

  create_table "laws", :force => true do |t|
    t.string   "category"
    t.string   "enacted_date"
    t.integer  "enacted_by_id"
    t.string   "revoked_date"
    t.integer  "revoked_by_id"
    t.integer  "refused_by_id"
    t.string   "target_type"
    t.integer  "target_id"
    t.boolean  "active",        :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "laws", ["active"], :name => "index_laws_on_active"
  add_index "laws", ["category"], :name => "index_laws_on_category"
  add_index "laws", ["target_id"], :name => "index_laws_on_target_id"
  add_index "laws", ["target_type"], :name => "index_laws_on_target_type"

  create_table "market_items", :force => true do |t|
    t.integer  "noble_house_id"
    t.integer  "item_id"
    t.integer  "world_id"
    t.integer  "quantity",       :default => 0
    t.float    "price"
    t.string   "listed_date"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "market_items", ["item_id"], :name => "index_market_items_on_item_id"
  add_index "market_items", ["noble_house_id"], :name => "index_market_items_on_noble_house_id"
  add_index "market_items", ["price"], :name => "index_market_items_on_price"
  add_index "market_items", ["world_id"], :name => "index_market_items_on_world_id"

  create_table "marriage_proposals", :force => true do |t|
    t.integer  "character_id"
    t.integer  "target_id"
    t.float    "dowry",         :default => 0.0
    t.string   "proposal_date"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "marriage_proposals", ["character_id"], :name => "index_marriage_proposals_on_character_id"
  add_index "marriage_proposals", ["target_id"], :name => "index_marriage_proposals_on_target_id"

  create_table "messages", :force => true do |t|
    t.string   "guid"
    t.integer  "character_id"
    t.integer  "from_id"
    t.string   "sent_date"
    t.integer  "reply_to_id"
    t.text     "subject"
    t.text     "content"
    t.text     "formatted_content"
    t.integer  "sovereigns",        :default => 0
    t.boolean  "archived",          :default => false
    t.boolean  "reported",          :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "messages", ["character_id"], :name => "index_messages_on_character_id"
  add_index "messages", ["from_id"], :name => "index_messages_on_from_id"
  add_index "messages", ["reply_to_id"], :name => "index_messages_on_reply_to_id"

  create_table "news", :force => true do |t|
    t.integer  "noble_house_id"
    t.string   "source_type"
    t.integer  "source_id"
    t.string   "target_type"
    t.integer  "target_id"
    t.string   "news_date"
    t.string   "code",           :default => ""
    t.boolean  "church",         :default => false
    t.boolean  "empire",         :default => false
    t.text     "description"
    t.boolean  "system_error"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "news", ["church"], :name => "index_news_on_church"
  add_index "news", ["code"], :name => "index_news_on_code"
  add_index "news", ["empire"], :name => "index_news_on_empire"
  add_index "news", ["news_date"], :name => "index_news_on_news_date"
  add_index "news", ["noble_house_id"], :name => "index_news_on_noble_house_id"
  add_index "news", ["source_id"], :name => "index_news_on_source_id"
  add_index "news", ["source_type"], :name => "index_news_on_source_type"
  add_index "news", ["target_id"], :name => "index_news_on_target_id"
  add_index "news", ["target_type"], :name => "index_news_on_target_type"

  create_table "noble_houses", :force => true do |t|
    t.integer  "player_id"
    t.integer  "baron_id"
    t.integer  "chancellor_id"
    t.string   "name"
    t.float    "wealth",        :default => 0.0
    t.float    "honour",        :default => 0.0
    t.float    "glory",         :default => 0.0
    t.float    "piety",         :default => 0.0
    t.string   "formed_date"
    t.boolean  "ancient",       :default => false
    t.boolean  "active",        :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "noble_houses", ["active"], :name => "index_noble_houses_on_active"
  add_index "noble_houses", ["ancient"], :name => "index_noble_houses_on_ancient"
  add_index "noble_houses", ["player_id"], :name => "index_noble_houses_on_player_id"

  create_table "order_parameters", :force => true do |t|
    t.integer  "order_id"
    t.string   "label"
    t.string   "parameter_type"
    t.string   "parameter_value"
    t.boolean  "required"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "order_parameters", ["label"], :name => "index_order_parameters_on_label"
  add_index "order_parameters", ["order_id"], :name => "index_order_parameters_on_order_id"

  create_table "orders", :force => true do |t|
    t.integer  "character_id"
    t.string   "code"
    t.string   "special_instruction"
    t.string   "signal",              :default => ""
    t.boolean  "finished",            :default => false
    t.string   "run_at"
    t.boolean  "success",             :default => false
    t.text     "error_msg"
    t.boolean  "run_chronum",         :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "orders", ["character_id"], :name => "index_orders_on_character_id"
  add_index "orders", ["code"], :name => "index_orders_on_code"
  add_index "orders", ["finished"], :name => "index_orders_on_finished"
  add_index "orders", ["run_chronum"], :name => "index_orders_on_run_chronum"
  add_index "orders", ["success"], :name => "index_orders_on_success"

  create_table "players", :force => true do |t|
    t.string   "guid"
    t.string   "name"
    t.string   "username",                              :null => false
    t.string   "email",                                 :null => false
    t.string   "crypted_password",                      :null => false
    t.string   "password_salt",                         :null => false
    t.string   "persistence_token",                     :null => false
    t.string   "perishable_token",   :default => "",    :null => false
    t.string   "string",             :default => "",    :null => false
    t.integer  "login_count",        :default => 0,     :null => false
    t.integer  "failed_login_count", :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.boolean  "gm",                 :default => false
    t.integer  "credits",            :default => 30
    t.boolean  "unlimited_credits",  :default => false
    t.boolean  "active",             :default => true
    t.boolean  "confirmed",          :default => false
    t.string   "confirm_code"
    t.boolean  "email_house_news",   :default => true
    t.boolean  "email_newsletter",   :default => true
    t.boolean  "email_messages",     :default => true
    t.datetime "last_house_news"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "new_news_flag",      :default => false
  end

  add_index "players", ["active"], :name => "index_players_on_active"
  add_index "players", ["confirm_code"], :name => "index_players_on_confirm_code"
  add_index "players", ["email"], :name => "index_players_on_email"
  add_index "players", ["gm"], :name => "index_players_on_gm"
  add_index "players", ["username"], :name => "index_players_on_username"

  create_table "populations", :force => true do |t|
    t.integer  "estate_id"
    t.string   "category"
    t.integer  "quantity",   :default => 0
    t.float    "morale",     :default => 1.0
    t.float    "wealth",     :default => 0.0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "populations", ["category"], :name => "index_populations_on_category"
  add_index "populations", ["estate_id"], :name => "index_populations_on_estate_id"

  create_table "prisoners", :force => true do |t|
    t.integer  "noble_house_id"
    t.integer  "estate_id"
    t.integer  "character_id"
    t.string   "captured_date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "prisoners", ["character_id"], :name => "index_prisoners_on_character_id"
  add_index "prisoners", ["estate_id"], :name => "index_prisoners_on_estate_id"
  add_index "prisoners", ["noble_house_id"], :name => "index_prisoners_on_noble_house_id"

  create_table "production_queues", :force => true do |t|
    t.integer  "estate_id"
    t.integer  "position",        :default => -1
    t.integer  "item_id"
    t.integer  "quantity",        :default => 1
    t.integer  "capacity_stored", :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "production_queues", ["estate_id"], :name => "index_production_queues_on_estate_id"
  add_index "production_queues", ["item_id"], :name => "index_production_queues_on_item_id"
  add_index "production_queues", ["position"], :name => "index_production_queues_on_position"

  create_table "ransoms", :force => true do |t|
    t.integer  "character_id"
    t.string   "offered_date"
    t.integer  "prisoner_id"
    t.float    "ransom",       :default => 0.0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "ransoms", ["character_id"], :name => "index_ransoms_on_character_id"
  add_index "ransoms", ["prisoner_id"], :name => "index_ransoms_on_prisoner_id"

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.string   "hemisphere",      :default => ""
    t.integer  "total_lands",     :default => 0
    t.integer  "unclaimed_lands", :default => 0
    t.integer  "infrastructure",  :default => 0
    t.string   "last_tribute",    :default => ""
    t.integer  "world_id"
    t.float    "church_funds",    :default => 0.0
    t.float    "alms",            :default => 100.0
    t.float    "education",       :default => 0.0
    t.float    "faith_projects",  :default => 0.0
    t.integer  "earl_id"
    t.integer  "bishop_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "regions", ["name"], :name => "index_regions_on_name"
  add_index "regions", ["total_lands"], :name => "index_regions_on_total_lands"
  add_index "regions", ["unclaimed_lands"], :name => "index_regions_on_unclaimed_lands"
  add_index "regions", ["world_id"], :name => "index_regions_on_world_id"

  create_table "resources", :force => true do |t|
    t.integer  "region_id"
    t.integer  "item_id"
    t.string   "yield_category", :default => "Normal"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "resources", ["item_id"], :name => "index_resources_on_item_id"
  add_index "resources", ["region_id"], :name => "index_resources_on_region_id"
  add_index "resources", ["yield_category"], :name => "index_resources_on_yield_category"

  create_table "scans", :force => true do |t|
    t.integer  "starship_id"
    t.integer  "world_id"
    t.integer  "target_id"
    t.string   "scan_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "scans", ["scan_date"], :name => "index_scans_on_scan_date"
  add_index "scans", ["starship_id"], :name => "index_scans_on_starship_id"
  add_index "scans", ["target_id"], :name => "index_scans_on_target_id"
  add_index "scans", ["world_id"], :name => "index_scans_on_world_id"

  create_table "sections", :force => true do |t|
    t.integer  "starship_id"
    t.integer  "item_id"
    t.integer  "quantity",    :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "sections", ["item_id"], :name => "index_sections_on_item_id"
  add_index "sections", ["starship_id"], :name => "index_sections_on_starship_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "skills", :force => true do |t|
    t.integer  "character_id"
    t.string   "category"
    t.string   "obtained_date"
    t.boolean  "training"
    t.string   "training_start_date"
    t.integer  "rank",                :default => 0
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "training_points",     :default => 0
  end

  add_index "skills", ["category"], :name => "index_skills_on_category"
  add_index "skills", ["character_id"], :name => "index_skills_on_character_id"
  add_index "skills", ["training"], :name => "index_skills_on_training"

  create_table "space_battles", :force => true do |t|
    t.integer  "attacker_id"
    t.integer  "defender_id"
    t.string   "location_type"
    t.integer  "location_id"
    t.string   "battle_date"
    t.text     "report"
    t.string   "battle_status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "space_battles", ["attacker_id"], :name => "index_space_battles_on_attacker_id"
  add_index "space_battles", ["defender_id"], :name => "index_space_battles_on_defender_id"
  add_index "space_battles", ["location_id"], :name => "index_space_battles_on_location_id"
  add_index "space_battles", ["location_type"], :name => "index_space_battles_on_location_type"

  create_table "starship_configuration_items", :force => true do |t|
    t.integer  "starship_configuration_id"
    t.integer  "item_id"
    t.integer  "quantity",                  :default => 0
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "starship_configuration_items", ["item_id"], :name => "index_starship_configuration_items_on_item_id"
  add_index "starship_configuration_items", ["starship_configuration_id"], :name => "index_starship_configuration_items_on_starship_configuration_id"

  create_table "starship_configurations", :force => true do |t|
    t.integer  "starship_type_id"
    t.integer  "noble_house_id"
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "starship_configurations", ["noble_house_id"], :name => "index_starship_configurations_on_noble_house_id"
  add_index "starship_configurations", ["starship_type_id"], :name => "index_starship_configurations_on_starship_type_id"

  create_table "starship_types", :force => true do |t|
    t.string   "name"
    t.integer  "hull_type_id"
    t.integer  "hull_size",        :default => 0
    t.string   "project_required", :default => ""
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "starship_types", ["hull_type_id"], :name => "index_starship_types_on_hull_type_id"
  add_index "starship_types", ["name"], :name => "index_starship_types_on_name"
  add_index "starship_types", ["project_required"], :name => "index_starship_types_on_project_required"

  create_table "starships", :force => true do |t|
    t.string   "guid"
    t.string   "name"
    t.integer  "noble_house_id"
    t.integer  "starship_type_id"
    t.integer  "starship_configuration_id"
    t.string   "built_date"
    t.integer  "built_by_id"
    t.integer  "built_location_id"
    t.integer  "hulls_assembled",           :default => 0
    t.string   "location_type"
    t.integer  "location_id"
    t.integer  "captain_id"
    t.integer  "hull_points",               :default => 0
    t.string   "destroyed_date"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "starships", ["guid"], :name => "index_starships_on_guid"
  add_index "starships", ["location_id"], :name => "index_starships_on_location_id"
  add_index "starships", ["location_type"], :name => "index_starships_on_location_type"
  add_index "starships", ["noble_house_id"], :name => "index_starships_on_noble_house_id"
  add_index "starships", ["starship_type_id"], :name => "index_starships_on_starship_type_id"

  create_table "titles", :force => true do |t|
    t.integer  "character_id"
    t.string   "obtained_date"
    t.string   "category"
    t.string   "sub_category"
    t.integer  "noble_house_id"
    t.integer  "estate_id"
    t.integer  "starship_id"
    t.integer  "army_id"
    t.integer  "unit_id"
    t.integer  "region_id"
    t.integer  "world_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "titles", ["army_id"], :name => "index_titles_on_army_id"
  add_index "titles", ["category"], :name => "index_titles_on_category"
  add_index "titles", ["character_id"], :name => "index_titles_on_character_id"
  add_index "titles", ["estate_id"], :name => "index_titles_on_estate_id"
  add_index "titles", ["noble_house_id"], :name => "index_titles_on_noble_house_id"
  add_index "titles", ["region_id"], :name => "index_titles_on_region_id"
  add_index "titles", ["starship_id"], :name => "index_titles_on_starship_id"
  add_index "titles", ["sub_category"], :name => "index_titles_on_sub_category"
  add_index "titles", ["unit_id"], :name => "index_titles_on_unit_id"
  add_index "titles", ["world_id"], :name => "index_titles_on_world_id"

  create_table "tournament_entrants", :force => true do |t|
    t.integer  "tournament_id"
    t.integer  "character_id"
    t.string   "joined_date"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tournament_entrants", ["character_id"], :name => "index_tournament_entrants_on_character_id"
  add_index "tournament_entrants", ["tournament_id"], :name => "index_tournament_entrants_on_tournament_id"

  create_table "tournaments", :force => true do |t|
    t.integer  "estate_id"
    t.integer  "winner_id"
    t.integer  "runner_up1_id"
    t.integer  "runner_up2_id"
    t.string   "event_date"
    t.float    "prize"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tournaments", ["estate_id"], :name => "index_tournaments_on_estate_id"
  add_index "tournaments", ["event_date"], :name => "index_tournaments_on_event_date"

  create_table "traits", :force => true do |t|
    t.integer  "character_id"
    t.string   "category"
    t.string   "acquired_date"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "traits", ["category"], :name => "index_traits_on_category"
  add_index "traits", ["character_id"], :name => "index_traits_on_character_id"

  create_table "units", :force => true do |t|
    t.string   "name"
    t.integer  "army_id"
    t.integer  "knight_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "units", ["army_id"], :name => "index_units_on_army_id"

  create_table "wedding_invites", :force => true do |t|
    t.integer  "wedding_id"
    t.integer  "character_id"
    t.string   "sent_date"
    t.boolean  "attended"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "wedding_invites", ["attended"], :name => "index_wedding_invites_on_attended"
  add_index "wedding_invites", ["character_id"], :name => "index_wedding_invites_on_character_id"
  add_index "wedding_invites", ["wedding_id"], :name => "index_wedding_invites_on_wedding_id"

  create_table "weddings", :force => true do |t|
    t.integer  "estate_id"
    t.integer  "groom_id"
    t.integer  "bride_id"
    t.string   "event_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "weddings", ["bride_id"], :name => "index_weddings_on_bride_id"
  add_index "weddings", ["estate_id"], :name => "index_weddings_on_estate_id"
  add_index "weddings", ["event_date"], :name => "index_weddings_on_event_date"
  add_index "weddings", ["groom_id"], :name => "index_weddings_on_groom_id"

  create_table "world_projects", :force => true do |t|
    t.integer  "world_id"
    t.string   "category"
    t.string   "build_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "world_projects", ["category"], :name => "index_world_projects_on_category"
  add_index "world_projects", ["world_id"], :name => "index_world_projects_on_world_id"

  create_table "worlds", :force => true do |t|
    t.string   "name"
    t.integer  "distance"
    t.integer  "quadrant"
    t.integer  "rotation"
    t.string   "last_imperial_tribute"
    t.string   "last_rotation"
    t.string   "last_tribute"
    t.float    "church_funds",          :default => 0.0
    t.integer  "duke_id"
    t.integer  "archbishop_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "worlds", ["name"], :name => "index_worlds_on_name"

end
