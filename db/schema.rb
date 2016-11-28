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

ActiveRecord::Schema.define(version: 20161128105521) do

  create_table "accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "uuid",                 limit: 32
    t.string   "mobile_number",        limit: 50
    t.string   "email",                limit: 50
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "authentication_token"
    t.string   "password_digest"
  end

  create_table "accounts_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "account_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "account_id"
    t.string   "wechat_id",       limit: 50
    t.string   "mobile_number",   limit: 50
    t.string   "nick_name",       limit: 50
    t.string   "heard_url",       limit: 50
    t.string   "real_name",       limit: 50
    t.string   "gender",          limit: 10
    t.integer  "age"
    t.string   "address"
    t.boolean  "is_wechat_focus"
    t.integer  "level"
    t.integer  "integral"
    t.string   "remark"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       limit: 50
    t.string   "remark"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "account_id"
    t.string   "name",          limit: 50
    t.string   "description"
    t.integer  "type"
    t.string   "address"
    t.string   "mobile_number", limit: 50
    t.string   "remark"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end
