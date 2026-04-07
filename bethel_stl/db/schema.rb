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

ActiveRecord::Schema[8.1].define(version: 2026_04_07_142113) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audio_extractions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "end_time"
    t.text "error_message"
    t.integer "file_size"
    t.string "filename"
    t.string "start_time"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "youtube_url", null: false
  end

  create_table "calendar_sources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "google_calendar_id"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "contact_group_memberships", force: :cascade do |t|
    t.integer "contact_group_id", null: false
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_group_id", "member_id"], name: "index_contact_group_memberships_uniqueness", unique: true
    t.index ["contact_group_id"], name: "index_contact_group_memberships_on_contact_group_id"
    t.index ["member_id"], name: "index_contact_group_memberships_on_member_id"
  end

  create_table "contact_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "documentable_id", null: false
    t.string "documentable_type", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "all_day", default: false, null: false
    t.integer "calendar_source_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at"
    t.string "google_event_id"
    t.string "location"
    t.boolean "public", default: false, null: false
    t.datetime "starts_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["calendar_source_id"], name: "index_events_on_calendar_source_id"
    t.index ["google_event_id"], name: "index_events_on_google_event_id"
    t.index ["public", "starts_at"], name: "index_events_on_public_and_starts_at"
  end

  create_table "households", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "state"
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zip"
  end

  create_table "members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.integer "household_id", null: false
    t.string "last_name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_members_on_household_id"
  end

  create_table "message_deliveries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.text "error_message"
    t.integer "member_id", null: false
    t.integer "message_id", null: false
    t.string "phone_or_email"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_message_deliveries_on_member_id"
    t.index ["message_id"], name: "index_message_deliveries_on_message_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.string "channel", default: "sms", null: false
    t.integer "contact_group_id"
    t.datetime "created_at", null: false
    t.integer "failed_count", default: 0
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.integer "sent_count", default: 0
    t.string "status", default: "scheduled", null: false
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["contact_group_id"], name: "index_messages_on_contact_group_id"
  end

  create_table "recordings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.date "recorded_on"
    t.string "speaker_name", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contact_group_memberships", "contact_groups"
  add_foreign_key "contact_group_memberships", "members"
  add_foreign_key "events", "calendar_sources"
  add_foreign_key "members", "households"
  add_foreign_key "message_deliveries", "members"
  add_foreign_key "message_deliveries", "messages"
  add_foreign_key "messages", "contact_groups"
end
