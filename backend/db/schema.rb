# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_03_142011) do
  create_table "matches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "utc_date"
    t.string "home_team"
    t.string "away_team"
    t.string "competition"
    t.string "score"
    t.string "venue"
    t.string "status"
    t.string "referees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "home_team_id"
    t.bigint "away_team_id"
    t.index ["away_team_id"], name: "fk_rails_6a75121a9b"
    t.index ["home_team_id"], name: "fk_rails_4aed6bdf0d"
  end

  create_table "players", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "number"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "position"
    t.integer "goals"
    t.integer "assists"
    t.integer "yellow_card"
    t.integer "red_card"
    t.integer "appearances"
    t.decimal "market_value", precision: 10
    t.integer "mvp"
    t.integer "salary"
  end

  create_table "teams", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "crest_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
end
