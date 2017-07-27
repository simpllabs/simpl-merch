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

ActiveRecord::Schema.define(version: 20170724205933) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "progress_stage"
    t.integer "progress_current", default: 0
    t.integer "progress_max", default: 0
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "female_inventories", force: :cascade do |t|
    t.integer "black_xs"
    t.integer "black_s"
    t.integer "black_m"
    t.integer "black_l"
    t.integer "black_xl"
    t.integer "black_2xl"
    t.integer "white_xs"
    t.integer "white_s"
    t.integer "white_m"
    t.integer "white_l"
    t.integer "white_xl"
    t.integer "white_2xl"
    t.integer "navy_xs"
    t.integer "navy_s"
    t.integer "navy_m"
    t.integer "navy_l"
    t.integer "navy_xl"
    t.integer "navy_2xl"
    t.integer "green_xs"
    t.integer "green_s"
    t.integer "green_m"
    t.integer "green_l"
    t.integer "green_xl"
    t.integer "green_2xl"
    t.integer "red_xs"
    t.integer "red_s"
    t.integer "red_m"
    t.integer "red_l"
    t.integer "red_xl"
    t.integer "red_2xl"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "male_inventories", force: :cascade do |t|
    t.integer "black_s"
    t.integer "black_m"
    t.integer "black_l"
    t.integer "black_xl"
    t.integer "black_2xl"
    t.integer "black_3xl"
    t.integer "white_s"
    t.integer "white_m"
    t.integer "white_l"
    t.integer "white_xl"
    t.integer "white_2xl"
    t.integer "white_3xl"
    t.integer "navy_s"
    t.integer "navy_m"
    t.integer "navy_l"
    t.integer "navy_xl"
    t.integer "navy_2xl"
    t.integer "navy_3xl"
    t.integer "green_s"
    t.integer "green_m"
    t.integer "green_l"
    t.integer "green_xl"
    t.integer "green_2xl"
    t.integer "green_3xl"
    t.integer "red_s"
    t.integer "red_m"
    t.integer "red_l"
    t.integer "red_xl"
    t.integer "red_2xl"
    t.integer "red_3xl"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "shop_domain"
    t.string "fulfillment_status"
    t.string "sku"
    t.integer "quantity"
    t.decimal "price", precision: 5, scale: 2
    t.string "name"
    t.boolean "processed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address1"
    t.string "address2"
    t.string "company"
    t.string "city"
    t.string "zip"
    t.string "province"
    t.string "country"
    t.string "front_design"
    t.string "back_design"
    t.string "front_ref"
    t.string "back_ref"
    t.string "product_name"
    t.string "shopify_order_id"
    t.string "shopify_line_item_id"
    t.string "gender"
    t.integer "tee_id"
    t.index ["shop_domain"], name: "index_orders_on_shop_domain"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.string "packing_slip"
    t.text "packing_slip_message"
    t.string "packing_slip_logo"
    t.string "email"
    t.string "chose_china_post"
    t.string "send_receipts"
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "tees", force: :cascade do |t|
    t.text "tee_front_url"
    t.text "tee_back_url"
    t.string "shop_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shopify_product_id"
    t.string "gender"
    t.string "tee_front_ref"
    t.string "tee_back_ref"
    t.boolean "one_time_fee_charged"
    t.boolean "back_one_time_fee_charged"
  end

end
