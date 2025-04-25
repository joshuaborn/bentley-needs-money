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

ActiveRecord::Schema[8.0].define(version: 2025_04_25_182055) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "connection_requests", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "connections", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "debts", force: :cascade do |t|
    t.integer "ower_id"
    t.integer "owed_id"
    t.integer "reason_id"
    t.integer "amount"
    t.integer "cumulative_sum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ower_reconciled"
    t.boolean "owed_reconciled"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "administrator"
    t.index ["confirmation_token"], name: "index_people_on_confirmation_token", unique: true
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true
  end

  create_table "person_transfers", force: :cascade do |t|
    t.integer "transfer_id"
    t.integer "person_id"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cumulative_sum"
    t.boolean "in_ynab"
  end

  create_table "reasons", force: :cascade do |t|
    t.string "type"
    t.date "date"
    t.string "payee"
    t.string "memo"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "signup_requests", force: :cascade do |t|
    t.integer "from_id"
    t.string "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfers", force: :cascade do |t|
    t.string "payee"
    t.string "memo"
    t.date "date"
    t.integer "amount_paid"
    t.date "reconciled_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["date"], name: "index_transfers_on_date"
  end

  add_foreign_key "connection_requests", "people", column: "from_id"
  add_foreign_key "connection_requests", "people", column: "to_id"
  add_foreign_key "connections", "people", column: "from_id"
  add_foreign_key "connections", "people", column: "to_id"
  add_foreign_key "person_transfers", "people"
  add_foreign_key "person_transfers", "transfers"
  add_foreign_key "signup_requests", "people", column: "from_id"
end
