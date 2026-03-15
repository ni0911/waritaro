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

ActiveRecord::Schema[8.0].define(version: 2026_03_15_125400) do
  create_table "cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "owner", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "setting_id", null: false
    t.index ["setting_id"], name: "index_cards_on_setting_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "member_a", default: "たろう", null: false
    t.string "member_b", default: "はなこ", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invite_code"
    t.bigint "owner_id"
    t.index ["invite_code"], name: "index_settings_on_invite_code", unique: true
  end

  create_table "sheet_items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "amount", default: 0, null: false
    t.integer "burden_a", default: 0, null: false
    t.integer "burden_b", default: 0, null: false
    t.integer "card_id"
    t.boolean "is_from_template", default: false, null: false
    t.integer "template_item_id"
    t.integer "sheet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_sheet_items_on_card_id"
    t.index ["sheet_id", "template_item_id"], name: "index_sheet_items_on_sheet_id_and_template_item_id", unique: true, where: "template_item_id IS NOT NULL"
    t.index ["sheet_id"], name: "index_sheet_items_on_sheet_id"
    t.index ["template_item_id"], name: "index_sheet_items_on_template_item_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.string "year_month", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "setting_id", null: false
    t.index ["setting_id"], name: "index_sheets_on_setting_id"
    t.index ["year_month", "setting_id"], name: "index_sheets_on_year_month_and_setting_id", unique: true
  end

  create_table "template_items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "amount", default: 0, null: false
    t.integer "burden_a", default: 0, null: false
    t.integer "burden_b", default: 0, null: false
    t.integer "card_id"
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "setting_id", null: false
    t.index ["card_id"], name: "index_template_items_on_card_id"
    t.index ["setting_id"], name: "index_template_items_on_setting_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "setting_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["setting_id"], name: "index_users_on_setting_id"
  end

  add_foreign_key "cards", "settings"
  add_foreign_key "sessions", "users"
  add_foreign_key "settings", "users", column: "owner_id"
  add_foreign_key "sheet_items", "cards"
  add_foreign_key "sheet_items", "sheets"
  add_foreign_key "sheet_items", "template_items"
  add_foreign_key "sheets", "settings"
  add_foreign_key "template_items", "cards"
  add_foreign_key "template_items", "settings"
  add_foreign_key "users", "settings"
end
