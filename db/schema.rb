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

ActiveRecord::Schema.define(version: 20170919215642) do

  create_table "game_weeks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_danish_ci" do |t|
    t.datetime "deadline_at"
    t.string "season"
    t.integer "gw_no"
    t.string "access_token"
    t.boolean "finished", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "last_sync_took", precision: 5, scale: 1
  end

  create_table "h2h_matches", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_danish_ci" do |t|
    t.integer "match_id"
    t.integer "match_order"
    t.integer "home_manager_id"
    t.integer "away_manager_id"
    t.integer "home_score"
    t.integer "away_score"
    t.text "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "home_chip"
    t.string "away_chip"
    t.integer "bp_prediction_home", default: 0
    t.integer "bp_prediction_away", default: 0
    t.integer "extra_points_home", default: 0
    t.integer "extra_points_away", default: 0
  end

  create_table "managers", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_danish_ci" do |t|
    t.integer "fpl_id"
    t.integer "team_id"
    t.string "fpl_name"
    t.string "fiso_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "squad_name"
  end

  create_table "matches", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_danish_ci" do |t|
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "gw_fixture_no"
    t.integer "game_week_id"
  end

  create_table "players", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_danish_ci" do |t|
    t.integer "h2h_match_id"
    t.integer "manager_id"
    t.string "name"
    t.integer "games_left"
    t.boolean "captain"
    t.boolean "vice_captain"
    t.boolean "bench"
    t.string "position"
    t.integer "points"
    t.integer "minutes_played"
    t.boolean "matches_over"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "side"
    t.integer "bp_prediction"
    t.index ["side", "h2h_match_id"], name: "index_players_on_side_and_h2h_match_id"
  end

  create_table "teams", id: :bigint, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_danish_ci" do |t|
    t.string "name"
    t.integer "fpl_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "fiso_team_id"
  end

end
