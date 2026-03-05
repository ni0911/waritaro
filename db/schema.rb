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

ActiveRecord::Schema[8.0].define(version: 2026_03_05_142005) do
  create_table "cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "owner", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "member_a", default: "たろう", null: false
    t.string "member_b", default: "はなこ", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["sheet_id"], name: "index_sheet_items_on_sheet_id"
    t.index ["template_item_id"], name: "index_sheet_items_on_template_item_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.string "year_month", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year_month"], name: "index_sheets_on_year_month", unique: true
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
    t.index ["card_id"], name: "index_template_items_on_card_id"
  end

  add_foreign_key "sheet_items", "cards"
  add_foreign_key "sheet_items", "sheets"
  add_foreign_key "sheet_items", "template_items"
  add_foreign_key "template_items", "cards"
end
