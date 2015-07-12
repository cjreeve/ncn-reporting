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

ActiveRecord::Schema.define(version: 20150701220346) do

  create_table "areas", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "areas", ["name"], name: "index_areas_on_name"

  create_table "categories", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true

  create_table "category_problem_selections", force: true do |t|
    t.integer  "category_id"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_problem_selections", ["category_id"], name: "index_category_problem_selections_on_category_id"
  add_index "category_problem_selections", ["problem_id"], name: "index_category_problem_selections_on_problem_id"

  create_table "images", force: true do |t|
    t.string   "url"
    t.string   "caption"
    t.integer  "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["issue_id"], name: "index_images_on_issue_id"

  create_table "issues", force: true do |t|
    t.integer  "issue_number",                    null: false
    t.string   "title",         default: "",      null: false
    t.text     "description",   default: "",      null: false
    t.integer  "priority"
    t.datetime "reported_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location_name", default: "",      null: false
    t.float    "lat"
    t.float    "lng"
    t.string   "state",         default: "draft", null: false
    t.integer  "route_id"
    t.string   "url"
    t.integer  "area_id"
    t.integer  "category_id"
    t.integer  "problem_id"
  end

  add_index "issues", ["area_id"], name: "index_issues_on_area_id"
  add_index "issues", ["category_id"], name: "index_issues_on_category_id"
  add_index "issues", ["completed_at"], name: "index_issues_on_completed_at"
  add_index "issues", ["issue_number"], name: "index_issues_on_issue_number", unique: true
  add_index "issues", ["lat"], name: "index_issues_on_lat"
  add_index "issues", ["lng"], name: "index_issues_on_lng"
  add_index "issues", ["location_name"], name: "index_issues_on_location_name"
  add_index "issues", ["problem_id"], name: "index_issues_on_problem_id"
  add_index "issues", ["reported_at"], name: "index_issues_on_reported_at"
  add_index "issues", ["route_id"], name: "index_issues_on_route_id"
  add_index "issues", ["state"], name: "index_issues_on_state"

  create_table "problems", force: true do |t|
    t.string   "name",             default: "", null: false
    t.integer  "default_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "problems", ["name"], name: "index_problems_on_name", unique: true

  create_table "routes", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "routes", ["name"], name: "index_routes_on_name", unique: true

end
