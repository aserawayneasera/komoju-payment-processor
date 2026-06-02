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

ActiveRecord::Schema[8.1].define(version: 2026_06_01_235033) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.bigint "merchant_id", null: false
    t.string "name", null: false
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_api_keys_on_merchant_id"
    t.index ["token_digest"], name: "index_api_keys_on_token_digest", unique: true
  end

  create_table "charges", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "JPY", null: false
    t.bigint "customer_id", null: false
    t.string "description"
    t.string "idempotency_key"
    t.bigint "merchant_id", null: false
    t.jsonb "metadata", default: {}
    t.bigint "payment_method_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_charges_on_customer_id"
    t.index ["merchant_id", "idempotency_key"], name: "index_charges_on_merchant_id_and_idempotency_key", unique: true, where: "(idempotency_key IS NOT NULL)"
    t.index ["merchant_id"], name: "index_charges_on_merchant_id"
    t.index ["payment_method_id"], name: "index_charges_on_payment_method_id"
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "merchant_id", null: false
    t.jsonb "metadata", default: {}
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "email"], name: "index_customers_on_merchant_id_and_email", unique: true
    t.index ["merchant_id"], name: "index_customers_on_merchant_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.bigint "merchant_id", null: false
    t.jsonb "payload", default: {}
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["merchant_id"], name: "index_events_on_merchant_id"
  end

  create_table "idempotency_keys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "locked_at"
    t.bigint "merchant_id", null: false
    t.string "request_path", null: false
    t.jsonb "response_body"
    t.integer "response_code"
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "key"], name: "index_idempotency_keys_on_merchant_id_and_key", unique: true
    t.index ["merchant_id"], name: "index_idempotency_keys_on_merchant_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_merchants_on_email", unique: true
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "brand"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.integer "exp_month"
    t.integer "exp_year"
    t.boolean "is_default", default: false
    t.string "last_four", null: false
    t.string "payment_type", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_payment_methods_on_customer_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.integer "amount", null: false
    t.bigint "charge_id", null: false
    t.datetime "created_at", null: false
    t.string "reason"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["charge_id"], name: "index_refunds_on_charge_id"
  end

  create_table "webhook_deliveries", force: :cascade do |t|
    t.integer "attempt_count", default: 0
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "next_retry_at"
    t.integer "response_code"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "webhook_endpoint_id", null: false
    t.index ["event_id"], name: "index_webhook_deliveries_on_event_id"
    t.index ["webhook_endpoint_id"], name: "index_webhook_deliveries_on_webhook_endpoint_id"
  end

  create_table "webhook_endpoints", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "events", default: [], array: true
    t.bigint "merchant_id", null: false
    t.string "secret_digest", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["merchant_id"], name: "index_webhook_endpoints_on_merchant_id"
  end

  add_foreign_key "api_keys", "merchants"
  add_foreign_key "charges", "customers"
  add_foreign_key "charges", "merchants"
  add_foreign_key "charges", "payment_methods"
  add_foreign_key "customers", "merchants"
  add_foreign_key "events", "merchants"
  add_foreign_key "idempotency_keys", "merchants"
  add_foreign_key "payment_methods", "customers"
  add_foreign_key "refunds", "charges"
  add_foreign_key "webhook_deliveries", "events"
  add_foreign_key "webhook_deliveries", "webhook_endpoints"
  add_foreign_key "webhook_endpoints", "merchants"
end
