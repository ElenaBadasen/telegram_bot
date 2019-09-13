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

ActiveRecord::Schema.define(version: 2018_07_21_123215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "chat_id"
    t.string "role"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "bots", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active"
    t.text "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "purpose"
    t.string "image_telegram_id"
  end

  create_table "bots_subscribers", id: false, force: :cascade do |t|
    t.bigint "bot_id", null: false
    t.bigint "subscriber_id", null: false
    t.index ["bot_id", "subscriber_id"], name: "index_bots_subscribers_on_bot_id_and_subscriber_id"
  end

  create_table "last_inline_buttons", force: :cascade do |t|
    t.bigint "subscriber_id"
    t.bigint "bot_id"
    t.string "telegram_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text"
    t.index ["bot_id"], name: "index_last_inline_buttons_on_bot_id"
    t.index ["subscriber_id", "bot_id"], name: "index_last_inline_buttons_on_subscriber_id_and_bot_id", unique: true
    t.index ["subscriber_id"], name: "index_last_inline_buttons_on_subscriber_id"
  end

  create_table "message_schedules", force: :cascade do |t|
    t.text "plain_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text "text"
    t.boolean "is_send"
    t.boolean "is_scheduled"
    t.datetime "scheduled_datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "separation"
    t.string "image_telegram_id"
    t.bigint "message_schedule_id"
    t.index ["message_schedule_id"], name: "index_messages_on_message_schedule_id"
  end

  create_table "separate_messages", force: :cascade do |t|
    t.bigint "message_id"
    t.bigint "bot_id"
    t.boolean "is_send"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subscriber_id"
    t.boolean "is_rejected"
    t.boolean "is_suspended"
    t.boolean "is_queued", default: false
    t.index ["bot_id"], name: "index_separate_messages_on_bot_id"
    t.index ["message_id"], name: "index_separate_messages_on_message_id"
    t.index ["subscriber_id"], name: "index_separate_messages_on_subscriber_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.string "chat_id", null: false
    t.boolean "watch_first_day"
    t.boolean "watch_second_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_subscribers_on_chat_id", unique: true
  end

end
