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

ActiveRecord::Schema.define(version: 20131019145313) do

  create_table "h2h_matches", force: true do |t|
    t.integer  "match_id"
    t.integer  "match_order"
    t.integer  "home_manager_id"
    t.integer  "away_manager_id"
    t.integer  "home_score"
    t.integer  "away_score"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "managers", force: true do |t|
    t.integer  "fpl_id"
    t.integer  "team_id"
    t.string   "fpl_name"
    t.string   "fiso_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matches", force: true do |t|
    t.integer  "game_week"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: true do |t|
    t.integer  "h2h_match_id"
    t.integer  "manager_id"
    t.string   "name"
    t.integer  "games_left"
    t.boolean  "captain"
    t.boolean  "vice_captain"
    t.boolean  "bench"
    t.string   "position"
    t.integer  "points"
    t.integer  "minutes_played"
    t.boolean  "match_over"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "match_status",   default: "over"
  end

  create_table "teams", force: true do |t|
    t.string   "name"
    t.integer  "fpl_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
