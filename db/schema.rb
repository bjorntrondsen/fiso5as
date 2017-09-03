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

ActiveRecord::Schema.define(version: 20170903212423) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_weeks", force: :cascade do |t|
    t.datetime "deadline_at"
    t.string "season"
    t.integer "gw_no"
    t.string "access_key"
    t.boolean "finished", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "h2h_matches", id: :serial, force: :cascade do |t|
    t.integer "match_id"
    t.integer "match_order"
    t.integer "home_manager_id"
    t.integer "away_manager_id"
    t.integer "home_score"
    t.integer "away_score"
    t.text "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "managers", id: :serial, force: :cascade do |t|
    t.integer "fpl_id"
    t.integer "team_id"
    t.string "fpl_name", limit: 255
    t.string "fiso_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "squad_name"
  end

  create_table "matches", id: :serial, force: :cascade do |t|
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "gw_fixture_no"
    t.integer "game_week_id"
  end

  create_table "players", id: :serial, force: :cascade do |t|
    t.integer "h2h_match_id"
    t.integer "manager_id"
    t.string "name", limit: 255
    t.integer "games_left"
    t.boolean "captain"
    t.boolean "vice_captain"
    t.boolean "bench"
    t.string "position", limit: 255
    t.integer "points"
    t.integer "minutes_played"
    t.boolean "match_over"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "match_status", limit: 255, default: "over"
    t.string "side"
    t.index ["side", "h2h_match_id"], name: "index_players_on_side_and_h2h_match_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "fpl_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "fiso_team_id"
  end

end
