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

ActiveRecord::Schema.define(version: 20170211004048) do

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

  create_table "adverts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "store_id"
    t.string   "img_url",     limit: 256
    t.string   "title",       limit: 256
    t.string   "description", limit: 256
    t.string   "link_url",    limit: 256
    t.integer  "status"
    t.integer  "category"
    t.string   "remark",      limit: 256
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "adverts_products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "adverts_id"
    t.integer "products_id"
    t.index ["adverts_id"], name: "index_adverts_products_on_adverts_id", using: :btree
    t.index ["products_id"], name: "index_adverts_products_on_products_id", using: :btree
  end

  create_table "bank_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.string   "card_number"
    t.string   "bank"
    t.boolean  "is_default"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "brands", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "category"
    t.integer  "status"
    t.string   "img_url"
    t.boolean  "is_recommend"
    t.string   "remark"
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "brands_products", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "brand_id"
    t.integer "product_id"
    t.index ["brand_id"], name: "index_brands_products_on_brand_id", using: :btree
    t.index ["product_id"], name: "index_brands_products_on_product_id", using: :btree
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

  create_table "customer_account_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "customer_id"
    t.datetime "trade_time"
    t.float    "expenses_receipts", limit: 24
    t.float    "balance",           limit: 24
    t.integer  "category"
    t.string   "remark",            limit: 256
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "customer_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.float    "withdraw_sum", limit: 24
    t.string   "remark"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "customer_id"
  end

  create_table "customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "account_id"
    t.string   "mobile_number", limit: 50
    t.string   "real_name",     limit: 50
    t.string   "gender",        limit: 10
    t.integer  "age"
    t.string   "address"
    t.integer  "level"
    t.integer  "integral"
    t.string   "remark"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "access_token",  limit: 256
    t.integer  "expires_in"
    t.string   "refresh_token", limit: 256
    t.string   "openid",        limit: 256
    t.string   "scope",         limit: 50
    t.string   "unionid",       limit: 256
    t.string   "nickname",      limit: 256
    t.integer  "sex"
    t.string   "province",      limit: 50
    t.string   "city",          limit: 50
    t.string   "country",       limit: 50
    t.string   "headimgurl",    limit: 256
    t.string   "privilege",     limit: 256
    t.string   "language",      limit: 50
  end

  create_table "detail_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       limit: 50
    t.string   "remark"
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "distribution_levels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.float    "commission_ratio", limit: 24
    t.string   "level"
    t.float    "minimum",          limit: 24
    t.float    "maximum",          limit: 24
    t.string   "remark",           limit: 256
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
  end

  create_table "distribution_rules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "store_id"
    t.string   "name",       limit: 256
    t.integer  "category"
    t.string   "value",      limit: 256
    t.string   "remark",     limit: 256
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "distribution_rules_stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "distribution_rule_id"
    t.integer "store_id"
    t.index ["distribution_rule_id"], name: "index_distribution_rules_stores_on_distribution_rule_id", using: :btree
    t.index ["store_id"], name: "index_distribution_rules_stores_on_store_id", using: :btree
  end

  create_table "distributions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "remark",         limit: 256
    t.integer  "parent_id"
    t.integer  "lft",                                    null: false
    t.integer  "rgt",                                    null: false
    t.integer  "depth",                      default: 0, null: false
    t.integer  "children_count",             default: 0, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["lft"], name: "index_distributions_on_lft", using: :btree
    t.index ["parent_id"], name: "index_distributions_on_parent_id", using: :btree
    t.index ["rgt"], name: "index_distributions_on_rgt", using: :btree
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "image_id"
    t.string   "document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "index_documents_on_image_id", using: :btree
  end

  create_table "images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "imageable_id"
    t.string   "imageable_type", limit: 50
    t.string   "remark"
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "picture"
    t.integer  "category"
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

  create_table "order_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.string   "operator_type"
    t.integer  "operator_id"
    t.integer  "action_number"
    t.datetime "operate_time"
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
    t.integer  "shipping_type"
    t.string   "shipping_number",   limit: 50
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
    t.integer  "store_id"
    t.string   "name"
    t.string   "description"
    t.string   "detail"
    t.integer  "stock"
    t.float    "price",       limit: 24
    t.float    "real_price",  limit: 24
    t.integer  "status"
    t.integer  "property"
    t.boolean  "is_deleted"
    t.string   "remark"
    t.datetime "deleted_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "category_id"
    t.integer  "group_id"
    t.string   "unit"
    t.integer  "amount"
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
    t.integer  "product_id"
    t.integer  "amount"
    t.string   "remark"
    t.boolean  "is_deleted"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "owner_id"
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

  create_table "system_storages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "category",        limit: 50
    t.string   "content",         limit: 256
    t.datetime "last_updated_at"
    t.boolean  "is_default"
    t.string   "remark",          limit: 256
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "withdraw_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "customer_id"
    t.integer  "store_id"
    t.float    "sum",          limit: 24
    t.datetime "operate_time"
    t.integer  "status"
    t.string   "remark"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "wxpay_notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.string   "appid",                limit: 32
    t.string   "mch_id",               limit: 32
    t.string   "device_info",          limit: 32
    t.string   "nonce_str",            limit: 32
    t.string   "sign",                 limit: 32
    t.string   "sign_type",            limit: 32
    t.string   "result_code",          limit: 16
    t.string   "err_code",             limit: 32
    t.string   "err_code_des",         limit: 128
    t.string   "openid",               limit: 128
    t.string   "is_subscribe",         limit: 1
    t.string   "trade_type",           limit: 16
    t.string   "bank_type",            limit: 16
    t.integer  "total_fee"
    t.integer  "settlement_total_fee"
    t.string   "fee_type",             limit: 8
    t.integer  "cash_fee"
    t.string   "cash_fee_type",        limit: 16
    t.string   "coupon_fee",           limit: 10
    t.string   "transaction_id",       limit: 32
    t.string   "out_trade_no",         limit: 32
    t.string   "attach",               limit: 128
    t.string   "time_end",             limit: 14
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_foreign_key "documents", "images"
end
