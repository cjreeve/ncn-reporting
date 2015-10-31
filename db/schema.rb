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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151030204803) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "administrative_areas", force: true do |t|
    t.string   "name",       null: false
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_id"
  end

  add_index "administrative_areas", ["area_id"], name: "index_administrative_areas_on_area_id", using: :btree
  add_index "administrative_areas", ["name"], name: "index_administrative_areas_on_name", unique: true, using: :btree
  add_index "administrative_areas", ["short_name"], name: "index_administrative_areas_on_short_name", unique: true, using: :btree

  create_table "areas", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "areas", ["name"], name: "index_areas_on_name", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "category_problem_selections", force: true do |t|
    t.integer  "category_id"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_problem_selections", ["category_id"], name: "index_category_problem_selections_on_category_id", using: :btree
  add_index "category_problem_selections", ["problem_id"], name: "index_category_problem_selections_on_problem_id", using: :btree

  create_table "comments", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["issue_id"], name: "index_comments_on_issue_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "images", force: true do |t|
    t.text     "url"
    t.string   "caption"
    t.integer  "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "src"
  end

  add_index "images", ["issue_id"], name: "index_images_on_issue_id", using: :btree

  create_table "issue_label_selections", force: true do |t|
    t.integer  "issue_id"
    t.integer  "label_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issue_label_selections", ["issue_id"], name: "index_issue_label_selections_on_issue_id", using: :btree
  add_index "issue_label_selections", ["label_id"], name: "index_issue_label_selections_on_label_id", using: :btree

  create_table "issues", force: true do |t|
    t.integer  "issue_number",                                           null: false
    t.string   "title",                  default: "",                    null: false
    t.text     "description",            default: "",                    null: false
    t.integer  "priority"
    t.datetime "reported_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location_name",          default: "",                    null: false
    t.float    "lat"
    t.float    "lng"
    t.string   "state",                  default: "draft",               null: false
    t.integer  "route_id"
    t.text     "url"
    t.integer  "area_id"
    t.integer  "category_id"
    t.integer  "problem_id"
    t.integer  "user_id"
    t.datetime "edited_at",              default: '2015-08-04 21:51:15', null: false
    t.integer  "administrative_area_id"
    t.integer  "editor_id"
    t.string   "resolution"
  end

  add_index "issues", ["administrative_area_id"], name: "index_issues_on_administrative_area_id", using: :btree
  add_index "issues", ["area_id"], name: "index_issues_on_area_id", using: :btree
  add_index "issues", ["category_id"], name: "index_issues_on_category_id", using: :btree
  add_index "issues", ["completed_at"], name: "index_issues_on_completed_at", using: :btree
  add_index "issues", ["editor_id"], name: "index_issues_on_editor_id", using: :btree
  add_index "issues", ["issue_number"], name: "index_issues_on_issue_number", unique: true, using: :btree
  add_index "issues", ["lat"], name: "index_issues_on_lat", using: :btree
  add_index "issues", ["lng"], name: "index_issues_on_lng", using: :btree
  add_index "issues", ["location_name"], name: "index_issues_on_location_name", using: :btree
  add_index "issues", ["problem_id"], name: "index_issues_on_problem_id", using: :btree
  add_index "issues", ["reported_at"], name: "index_issues_on_reported_at", using: :btree
  add_index "issues", ["route_id"], name: "index_issues_on_route_id", using: :btree
  add_index "issues", ["state"], name: "index_issues_on_state", using: :btree
  add_index "issues", ["user_id"], name: "index_issues_on_user_id", using: :btree

  create_table "labels", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "content"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "problems", force: true do |t|
    t.string   "name",             default: "", null: false
    t.integer  "default_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "problems", ["name"], name: "index_problems_on_name", unique: true, using: :btree

  create_table "routes", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       default: "", null: false
  end

  add_index "routes", ["slug"], name: "index_routes_on_slug", unique: true, using: :btree

  create_table "user_label_selections", force: true do |t|
    t.integer  "user_id"
    t.integer  "label_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_label_selections", ["label_id"], name: "index_user_label_selections_on_label_id", using: :btree
  add_index "user_label_selections", ["user_id"], name: "index_user_label_selections_on_user_id", using: :btree

  create_table "user_managed_area_selections", force: true do |t|
    t.integer  "user_id"
    t.integer  "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_managed_area_selections", ["area_id"], name: "index_user_managed_area_selections_on_area_id", using: :btree
  add_index "user_managed_area_selections", ["user_id"], name: "index_user_managed_area_selections_on_user_id", using: :btree

  create_table "user_managed_route_selections", force: true do |t|
    t.integer  "user_id"
    t.integer  "route_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_managed_route_selections", ["route_id"], name: "index_user_managed_route_selections_on_route_id", using: :btree
  add_index "user_managed_route_selections", ["user_id"], name: "index_user_managed_route_selections_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",                    null: false
    t.string   "encrypted_password",     default: "",                    null: false
    t.string   "role",                   default: "",                    null: false
    t.string   "name",                   default: "",                    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "is_admin",               default: false
    t.boolean  "is_locked",              default: false
    t.datetime "visited_updates_at",     default: '2015-10-19 19:56:56', null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree

end
