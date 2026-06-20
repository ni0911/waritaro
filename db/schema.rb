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

ActiveRecord::Schema[8.1].define(version: 2026_06_20_010008) do
  create_table "expense_shares", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "expense_id", null: false
    t.integer "member_id", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_id", "member_id"], name: "index_expense_shares_on_expense_id_and_member_id", unique: true
    t.index ["expense_id"], name: "index_expense_shares_on_expense_id"
    t.index ["member_id"], name: "index_expense_shares_on_member_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.date "expense_date", null: false
    t.integer "group_id", null: false
    t.integer "payer_id", null: false
    t.integer "settlement_id"
    t.string "split_mode", default: "equal", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "expense_date"], name: "index_expenses_on_group_id_and_expense_date"
    t.index ["group_id"], name: "index_expenses_on_group_id"
    t.index ["payer_id"], name: "index_expenses_on_payer_id"
    t.index ["settlement_id"], name: "index_expenses_on_settlement_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "icon", default: "🏠", null: false
    t.string "invite_code"
    t.string "kind", default: "general", null: false
    t.string "name"
    t.bigint "owner_id"
    t.string "tile", default: "#E7D3C2", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_code"], name: "index_groups_on_invite_code", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "color", default: "#C8704F", null: false
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.string "name", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["group_id", "user_id"], name: "index_members_on_group_id_and_user_id", unique: true, where: "user_id IS NOT NULL"
    t.index ["group_id"], name: "index_members_on_group_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settlements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.string "note"
    t.datetime "settled_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_settlements_on_group_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "expense_shares", "expenses"
  add_foreign_key "expense_shares", "members"
  add_foreign_key "expenses", "groups"
  add_foreign_key "expenses", "members", column: "payer_id"
  add_foreign_key "expenses", "settlements"
  add_foreign_key "groups", "users", column: "owner_id"
  add_foreign_key "members", "groups"
  add_foreign_key "members", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "settlements", "groups"
end
