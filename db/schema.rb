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

ActiveRecord::Schema[8.1].define(version: 2026_01_04_030209) do
  create_table "exercise_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "exercise_seconds", default: 30
    t.integer "exercise_set_id", null: false
    t.string "name"
    t.integer "position"
    t.integer "rest_seconds", default: 15
    t.datetime "updated_at", null: false
    t.index ["exercise_set_id"], name: "index_exercise_items_on_exercise_set_id"
  end

  create_table "exercise_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "rounds", default: 1
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_exercise_sets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  create_table "workout_logs", force: :cascade do |t|
    t.boolean "completed", default: true, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "date"], name: "index_workout_logs_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_workout_logs_on_user_id"
  end

  add_foreign_key "exercise_items", "exercise_sets"
  add_foreign_key "exercise_sets", "users"
  add_foreign_key "workout_logs", "users"
end
