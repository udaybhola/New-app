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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180409072825) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "uuid-ossp"
  enable_extension "pgcrypto"

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "activable_id"
    t.string "activable_type", default: "", null: false
    t.jsonb "meta", default: {}, null: false
    t.jsonb "details", default: {}, null: false
    t.integer "score", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false, null: false
    t.index ["activable_id"], name: "index_activities_on_activable_id"
    t.index ["activable_type", "activable_id"], name: "index_activities_on_activable_type_and_activable_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "attachable_id"
    t.string "attachable_type", default: "", null: false
    t.string "media", default: "", null: false
    t.string "caption", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_id"], name: "index_attachments_on_attachable_id"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable_type_and_attachable_id"
  end

  create_table "bulk_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "election_id"
    t.string "file"
    t.string "name"
    t.string "status", default: "", null: false
    t.jsonb "notes", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["election_id"], name: "index_bulk_files_on_election_id"
  end

  create_table "candidate_nominations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.uuid "party_id"
    t.string "age", default: "12", null: false
    t.string "election_kind", default: "assembly", null: false
    t.uuid "country_state_id"
    t.uuid "parliament_id"
    t.uuid "assembly_id"
    t.jsonb "meta", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "candidate_votes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "candidature_id"
    t.uuid "election_id"
    t.boolean "is_valid", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "previous_vote_id"
    t.uuid "new_vote_id"
    t.boolean "archived", default: false, null: false
    t.index ["candidature_id"], name: "index_candidate_votes_on_candidature_id"
    t.index ["election_id"], name: "index_candidate_votes_on_election_id"
    t.index ["new_vote_id"], name: "index_candidate_votes_on_new_vote_id"
    t.index ["previous_vote_id"], name: "index_candidate_votes_on_previous_vote_id"
    t.index ["user_id"], name: "index_candidate_votes_on_user_id"
  end

  create_table "candidates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "phone_number", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "label_id"
    t.boolean "should_link_with_phone_number", default: false
    t.string "link_phone_number", default: "", null: false
    t.index ["label_id"], name: "index_candidates_on_label_id"
  end

  create_table "candidatures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_id"
    t.uuid "party_id"
    t.uuid "election_id"
    t.boolean "declared", default: false
    t.string "manifesto", default: "", null: false
    t.string "result", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "constituency_id"
    t.jsonb "data", default: {}, null: false
    t.string "firebase_url", default: ""
    t.string "firebase_link_response", default: ""
    t.float "initial_vote_percent", default: 0.0, null: false
    t.index ["candidate_id"], name: "index_candidatures_on_candidate_id"
    t.index ["constituency_id"], name: "index_candidatures_on_constituency_id"
    t.index ["election_id"], name: "index_candidatures_on_election_id"
    t.index ["party_id"], name: "index_candidatures_on_party_id"
  end

  create_table "castes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "slug", default: "", null: false
    t.string "image", default: "", null: false
  end

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "post_id"
    t.uuid "parent_id"
    t.string "text", default: "", null: false
    t.integer "score", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "newly_created"
    t.boolean "archived", default: false, null: false
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "constituencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "country_state_id"
    t.string "name", default: "", null: false
    t.string "slug", default: "", null: false
    t.string "kind", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "parent_id"
    t.jsonb "cloudinary_response", default: {}, null: false
    t.jsonb "map_meta"
    t.index ["country_state_id"], name: "index_constituencies_on_country_state_id"
    t.index ["parent_id"], name: "index_constituencies_on_parent_id"
  end

  create_table "constituencies_districts", id: false, force: :cascade do |t|
    t.uuid "constituency_id"
    t.uuid "district_id"
    t.index ["constituency_id"], name: "index_constituencies_districts_on_constituency_id"
    t.index ["district_id"], name: "index_constituencies_districts_on_district_id"
  end

  create_table "country_states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "slug", default: "", null: false
    t.string "code", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_union_territory", default: false, null: false
    t.boolean "launched", default: false, null: false
    t.jsonb "assembly_geojson", default: {}, null: false
    t.jsonb "parliamentary_geojson", default: {}, null: false
    t.jsonb "geo_center", default: {}, null: false
    t.jsonb "geo_bounding_coords"
  end

  create_table "dashboard_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type"
    t.string "item_sub_type"
    t.uuid "item_type_resource_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "cloudinary_response", default: {}, null: false
    t.index ["item_type", "item_sub_type", "item_type_resource_id"], name: "type_resource_index"
  end

  create_table "districts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "country_state_id"
    t.string "name", default: "", null: false
    t.string "slug", default: "", null: false
    t.index ["country_state_id"], name: "index_districts_on_country_state_id"
  end

  create_table "educations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "elections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "kind", default: "", null: false
    t.date "starts_at"
    t.date "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "country_state_id"
    t.index ["country_state_id"], name: "index_elections_on_country_state_id"
  end

  create_table "firebase_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.jsonb "firebase_response", default: {}, null: false
    t.index ["uid"], name: "index_firebase_users_on_uid", unique: true
  end

  create_table "flaggings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "flaggable_type"
    t.uuid "flaggable_id"
    t.uuid "flag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flag_id"], name: "index_flaggings_on_flag_id"
    t.index ["flaggable_type", "flaggable_id"], name: "index_flaggings_on_flaggable_type_and_flaggable_id"
  end

  create_table "flags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reason", default: "", null: false
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_flags_on_user_id"
  end

  create_table "labels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "color", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "language_labels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key"
    t.jsonb "translations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_language_labels_on_key", unique: true
  end

  create_table "languages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.boolean "availability", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_languages_on_name", unique: true
  end

  create_table "likes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "likeable_id"
    t.string "likeable_type", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false, null: false
    t.index ["likeable_id"], name: "index_likes_on_likeable_id"
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "maps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "mappable_id"
    t.string "mappable_type"
    t.string "name"
    t.string "kind", default: "", null: false
    t.string "state_name"
    t.string "state_code"
    t.geometry "shape", limit: {:srid=>4326, :type=>"multi_polygon"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mappable_id"], name: "index_maps_on_mappable_id"
    t.index ["mappable_type", "mappable_id"], name: "index_maps_on_mappable_type_and_mappable_id"
    t.index ["shape"], name: "index_maps_on_shape", using: :gist
  end

  create_table "maps_ref_ac", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.integer "objectid"
    t.string "st_code", limit: 254
    t.string "st_name", limit: 254
    t.string "dt_code", limit: 254
    t.string "dist_name", limit: 254
    t.decimal "ac_no"
    t.string "ac_name", limit: 254
    t.decimal "pc_no"
    t.string "pc_name", limit: 254
    t.decimal "pc_id"
    t.string "status", limit: 254
    t.decimal "shape_leng"
    t.decimal "shape_area"
    t.geometry "geom", limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  create_table "maps_ref_pc", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.string "st_name", limit: 254
    t.string "pc_name", limit: 254
    t.string "st_code", limit: 3
    t.integer "pc_code", limit: 2
    t.string "res", limit: 4
    t.geometry "geom", limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  create_table "maps_ref_states", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.string "st_nm", limit: 24
    t.geometry "geom", limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidature_id"
    t.string "title", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidature_id"], name: "index_messages_on_candidature_id"
  end

  create_table "mobile_app_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", default: "", null: false
    t.jsonb "value", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "image", default: "", null: false
    t.string "manifesto"
    t.jsonb "info", default: {}, null: false
    t.jsonb "contact", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abbreviation", default: "", null: false
    t.string "color", default: "", null: false
  end

  create_table "party_leader_positions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "position_hierarchy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "party_leaders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "party_id"
    t.uuid "candidate_id"
    t.string "post", default: "", null: false
    t.integer "post_hierarchical_postion", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "party_leader_position_id"
    t.index ["candidate_id"], name: "index_party_leaders_on_candidate_id"
    t.index ["party_id"], name: "index_party_leaders_on_party_id"
    t.index ["party_leader_position_id"], name: "index_party_leaders_on_party_leader_position_id"
  end

  create_table "party_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "party_id"
    t.boolean "is_valid", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "constituency_id"
    t.string "description"
    t.index ["constituency_id"], name: "index_party_memberships_on_constituency_id"
    t.index ["party_id"], name: "index_party_memberships_on_party_id"
    t.index ["user_id"], name: "index_party_memberships_on_user_id"
  end

  create_table "poll_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "poll_id"
    t.string "answer", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "poll_votes_count", default: 0, null: false
    t.integer "position", default: 0
    t.string "image", default: "", null: false
    t.index ["poll_id"], name: "index_poll_options_on_poll_id"
  end

  create_table "poll_votes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "poll_option_id"
    t.boolean "is_valid", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "poll_id"
    t.boolean "archived", default: false, null: false
    t.index ["poll_id"], name: "index_poll_votes_on_poll_id"
    t.index ["poll_option_id"], name: "index_poll_votes_on_poll_option_id"
    t.index ["user_id"], name: "index_poll_votes_on_user_id"
  end

  create_table "posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "region_id"
    t.uuid "category_id"
    t.string "type", default: "", null: false
    t.string "slug", default: "", null: false
    t.string "title", default: "", null: false
    t.string "description", default: "", null: false
    t.string "question", default: "", null: false
    t.boolean "anonymous", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.string "region_type", default: "", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "status", default: "newly_created"
    t.boolean "show_on_dashboard", default: false, null: false
    t.boolean "archived", default: false, null: false
    t.integer "position", default: 0, null: false
    t.string "firebase_url", default: ""
    t.string "firebase_link_response", default: ""
    t.boolean "poll_options_as_image", default: false, null: false
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["is_admin"], name: "index_posts_on_is_admin"
    t.index ["region_id"], name: "index_posts_on_region_id"
    t.index ["region_type", "region_id"], name: "index_posts_on_region_type_and_region_id"
    t.index ["region_type"], name: "index_posts_on_region_type"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "professions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "candidate_id"
    t.uuid "religion_id"
    t.uuid "caste_id"
    t.uuid "education_id"
    t.uuid "profession_id"
    t.string "profile_pic", default: "", null: false
    t.string "cover_photo", default: "", null: false
    t.string "name", default: "", null: false
    t.string "slug", default: "", null: false
    t.datetime "date_of_birth", default: "1990-01-01 00:00:00"
    t.string "gender", default: "", null: false
    t.jsonb "contact", default: {}, null: false
    t.jsonb "financials", default: {}, null: false
    t.jsonb "civil_record", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "status", default: {}, null: false
    t.index ["candidate_id"], name: "index_profiles_on_candidate_id"
    t.index ["caste_id"], name: "index_profiles_on_caste_id"
    t.index ["education_id"], name: "index_profiles_on_education_id"
    t.index ["profession_id"], name: "index_profiles_on_profession_id"
    t.index ["religion_id"], name: "index_profiles_on_religion_id"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "religions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number", default: "", null: false
    t.string "firebase_user_id", default: "", null: false
    t.uuid "constituency_id"
    t.string "firebase_url", default: ""
    t.string "firebase_link_response", default: ""
    t.boolean "archived", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["constituency_id"], name: "index_users_on_constituency_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["firebase_user_id"], name: "index_users_on_firebase_user_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
