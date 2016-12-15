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

ActiveRecord::Schema.define(version: 20161214030923) do

  create_table "accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "uuid"
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

  create_table "addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "customer_id"
    t.string   "mobile_number",    limit: 50
    t.string   "detailed_address", limit: 1024
    t.boolean  "is_default"
    t.string   "remark"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft",                        null: false
    t.integer  "rgt",                        null: false
    t.integer  "depth",          default: 0, null: false
    t.integer  "children_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["lft"], name: "index_categories_on_lft", using: :btree
    t.index ["parent_id"], name: "index_categories_on_parent_id", using: :btree
    t.index ["rgt"], name: "index_categories_on_rgt", using: :btree
  end

  create_table "categories_classifications", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "Category_id"
    t.integer "Classification_id"
    t.index ["Category_id"], name: "index_categories_classifications_on_Category_id", using: :btree
    t.index ["Classification_id"], name: "index_categories_classifications_on_Classification_id", using: :btree
  end

  create_table "categories_products", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "category_id"
    t.integer "product_id"
    t.index ["category_id"], name: "index_categories_products_on_category_id", using: :btree
    t.index ["product_id"], name: "index_categories_products_on_product_id", using: :btree
  end

  create_table "classifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft",                        null: false
    t.integer  "rgt",                        null: false
    t.integer  "depth",          default: 0, null: false
    t.integer  "children_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["lft"], name: "index_classifications_on_lft", using: :btree
    t.index ["parent_id"], name: "index_classifications_on_parent_id", using: :btree
    t.index ["rgt"], name: "index_classifications_on_rgt", using: :btree
  end

  create_table "collections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "object_type"
    t.integer  "object_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.boolean  "is_deleted"
    t.string   "remark"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
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

  create_table "detail_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       limit: 50,              comment: "属性名字"
    t.string   "remark",                             comment: "属性备注"
    t.boolean  "is_deleted",                         comment: "-1:已删除 0:正常"
    t.datetime "deleted_at",                         comment: "删除时间"
    t.datetime "created_at",            null: false, comment: "创建时间"
    t.datetime "updated_at",            null: false
  end

  create_table "order_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.float    "price",      limit: 24
    t.boolean  "is_default"
    t.string   "remark",     limit: 256
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "order_number",      limit: 256
    t.integer  "status"
    t.float    "total_price",       limit: 24
    t.integer  "buyer_id"
    t.string   "buyer_type",        limit: 50
    t.integer  "estimate"
    t.string   "remark"
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "pay_away"
    t.datetime "time_start"
    t.datetime "time_expire"
    t.string   "consignee_name",    limit: 32
    t.string   "consignee_phone",   limit: 32
    t.string   "consignee_address", limit: 256
    t.float    "pay_price",         limit: 24
  end

  create_table "orders_products", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.index ["order_id"], name: "index_orders_products_on_order_id", using: :btree
    t.index ["product_id"], name: "index_orders_products_on_product_id", using: :btree
  end

  create_table "pictures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "imageable_id"
    t.string   "imageable_type", limit: 50
    t.string   "remark"
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "category"
  end

  create_table "product_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "product_id"
    t.integer  "detail_item_id"
    t.string   "content",        limit: 50
    t.boolean  "is_deleted"
    t.string   "remark"
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "uuid"
    t.integer  "store_id",                                            comment: "所属商家"
    t.string   "name"
    t.string   "description"
    t.string   "detail",                                              comment: "商品详情信息"
    t.integer  "stock",                                               comment: "库存"
    t.float    "price",       limit: 24,                              comment: "价格"
    t.float    "real_price",  limit: 24,                              comment: "优惠价格"
    t.integer  "status"
    t.integer  "property"
    t.boolean  "is_deleted",             default: false,              comment: "-1：已删除 0:未上架 1:已上架"
    t.string   "remark",                                              comment: "备注"
    t.datetime "deleted_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "category_id"
  end

  create_table "products_stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "store_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_products_stores_on_product_id", using: :btree
    t.index ["store_id"], name: "index_products_stores_on_store_id", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       limit: 50
    t.string   "remark"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "shopping_carts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "product_id",              comment: "产品ID"
    t.integer  "amount",                  comment: "产品数量"
    t.string   "remark",                  comment: "备注"
    t.boolean  "is_deleted",              comment: "-1：删除 1：正常"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "owner_id",                comment: "用户ID"
    t.string   "owner_type"
  end

  create_table "stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "account_id"
    t.string   "name",          limit: 50
    t.string   "description"
    t.integer  "property"
    t.string   "address"
    t.string   "mobile_number", limit: 50
    t.string   "remark"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end
