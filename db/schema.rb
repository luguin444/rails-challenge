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

ActiveRecord::Schema[7.1].define(version: 2024_10_02_024046) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_currencies_on_symbol", unique: true
  end

  create_table "currency_rates", force: :cascade do |t|
    t.bigint "upload_file_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "rate", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_currency_rates_on_currency_id"
    t.index ["upload_file_id", "currency_id"], name: "index_currency_rates_on_upload_file_id_and_currency_id", unique: true
    t.index ["upload_file_id"], name: "index_currency_rates_on_upload_file_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", null: false
    t.string "expiration", null: false
    t.string "code", null: false
    t.bigint "upload_file_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expiration"], name: "index_products_on_expiration"
    t.index ["name"], name: "index_products_on_name"
    t.index ["price"], name: "index_products_on_price"
    t.index ["upload_file_id"], name: "index_products_on_upload_file_id"
  end

  create_table "upload_files", force: :cascade do |t|
    t.string "file_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_url"], name: "index_upload_files_on_file_url", unique: true
  end

  add_foreign_key "currency_rates", "currencies"
  add_foreign_key "currency_rates", "upload_files"
  add_foreign_key "products", "upload_files"
end
