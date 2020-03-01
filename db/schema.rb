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

ActiveRecord::Schema.define(version: 2019_06_09_164859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "administrative_areas", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "short_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "group_id"
    t.string "reporting_url"
    t.index ["group_id"], name: "index_administrative_areas_on_group_id"
    t.index ["name"], name: "index_administrative_areas_on_name", unique: true
    t.index ["short_name"], name: "index_administrative_areas_on_short_name", unique: true
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "category_problem_selections", id: :serial, force: :cascade do |t|
    t.integer "category_id"
    t.integer "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id"], name: "index_category_problem_selections_on_category_id"
    t.index ["problem_id"], name: "index_category_problem_selections_on_problem_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "user_id"
    t.integer "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["issue_id"], name: "index_comments_on_issue_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "region_id"
    t.index ["name"], name: "index_groups_on_name"
    t.index ["region_id"], name: "index_groups_on_region_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.text "url"
    t.string "caption", limit: 255
    t.integer "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "src", limit: 255
    t.integer "rotation"
    t.string "owner_type"
    t.integer "comment_id"
    t.date "taken_on"
    t.index ["comment_id"], name: "index_images_on_comment_id"
    t.index ["owner_id"], name: "index_images_on_owner_id"
    t.index ["owner_type"], name: "index_images_on_owner_type"
    t.index ["taken_on"], name: "index_images_on_taken_on"
  end

  create_table "issue_follower_selections", id: :serial, force: :cascade do |t|
    t.integer "issue_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_issue_follower_selections_on_issue_id"
    t.index ["user_id"], name: "index_issue_follower_selections_on_user_id"
  end

  create_table "issue_label_selections", id: :serial, force: :cascade do |t|
    t.integer "issue_id"
    t.integer "label_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["issue_id"], name: "index_issue_label_selections_on_issue_id"
    t.index ["label_id"], name: "index_issue_label_selections_on_label_id"
  end

  create_table "issues", id: :serial, force: :cascade do |t|
    t.integer "issue_number", null: false
    t.string "title", limit: 255, default: "", null: false
    t.text "description", default: "", null: false
    t.integer "priority"
    t.datetime "reported_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "location_name", limit: 255, default: "", null: false
    t.float "lat"
    t.float "lng"
    t.string "state", limit: 255, default: "draft", null: false
    t.integer "route_id"
    t.text "url"
    t.integer "group_id"
    t.integer "category_id"
    t.integer "problem_id"
    t.integer "user_id"
    t.datetime "edited_at", default: "2015-08-04 21:51:15", null: false
    t.integer "administrative_area_id"
    t.integer "editor_id"
    t.string "resolution", limit: 255
    t.index ["administrative_area_id"], name: "index_issues_on_administrative_area_id"
    t.index ["category_id"], name: "index_issues_on_category_id"
    t.index ["completed_at"], name: "index_issues_on_completed_at"
    t.index ["editor_id"], name: "index_issues_on_editor_id"
    t.index ["group_id"], name: "index_issues_on_group_id"
    t.index ["issue_number"], name: "index_issues_on_issue_number", unique: true
    t.index ["lat"], name: "index_issues_on_lat"
    t.index ["lng"], name: "index_issues_on_lng"
    t.index ["location_name"], name: "index_issues_on_location_name"
    t.index ["problem_id"], name: "index_issues_on_problem_id"
    t.index ["reported_at"], name: "index_issues_on_reported_at"
    t.index ["route_id"], name: "index_issues_on_route_id"
    t.index ["state"], name: "index_issues_on_state"
    t.index ["user_id"], name: "index_issues_on_user_id"
  end

  create_table "labels", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.text "content"
    t.string "role", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "problems", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
    t.integer "default_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_problems_on_name", unique: true
  end

  create_table "regions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.float "lat", default: 0.0
    t.float "lng", default: 0.0, null: false
    t.integer "map_zoom", default: 11, null: false
    t.string "email", limit: 255
    t.string "email_name", limit: 255
    t.datetime "notifications_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", limit: 255, default: "", null: false
    t.index ["slug"], name: "index_routes_on_slug", unique: true
  end

  create_table "twins", id: :serial, force: :cascade do |t|
    t.integer "issue_id"
    t.integer "twinned_issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id", "twinned_issue_id"], name: "index_twins_on_issue_id_and_twinned_issue_id", unique: true
    t.index ["issue_id"], name: "index_twins_on_issue_id"
    t.index ["twinned_issue_id"], name: "index_twins_on_twinned_issue_id"
  end

  create_table "user_admin_area_selections", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "administrative_area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrative_area_id"], name: "index_user_admin_area_selections_on_administrative_area_id"
    t.index ["user_id"], name: "index_user_admin_area_selections_on_user_id"
  end

  create_table "user_label_selections", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "label_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["label_id"], name: "index_user_label_selections_on_label_id"
    t.index ["user_id"], name: "index_user_label_selections_on_user_id"
  end

  create_table "user_managed_group_selections", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "index_user_managed_group_selections_on_group_id"
    t.index ["user_id"], name: "index_user_managed_group_selections_on_user_id"
  end

  create_table "user_managed_route_selections", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "route_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["route_id"], name: "index_user_managed_route_selections_on_route_id"
    t.index ["user_id"], name: "index_user_managed_route_selections_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "role", limit: 255, default: "", null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.boolean "is_locked", default: false
    t.datetime "visited_updates_at", default: "2015-10-19 22:48:42", null: false
    t.boolean "receive_email_notifications", default: true, null: false
    t.integer "region_id"
    t.integer "creator_id"
    t.string "issue_filter_mode"
    t.index ["creator_id"], name: "index_users_on_creator_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["region_id"], name: "index_users_on_region_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "groups", "regions"
  add_foreign_key "images", "comments"
  add_foreign_key "issue_follower_selections", "issues"
  add_foreign_key "issue_follower_selections", "users"
  add_foreign_key "twins", "issues"
  add_foreign_key "twins", "issues", column: "twinned_issue_id"
  add_foreign_key "user_admin_area_selections", "administrative_areas"
  add_foreign_key "user_admin_area_selections", "users"
end
