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

ActiveRecord::Schema[8.1].define(version: 2026_08_18_000000) do
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

  create_table "conference_answers", force: :cascade do |t|
    t.integer "conference_question_id", null: false
    t.integer "conference_registration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["conference_question_id"], name: "index_conference_answers_on_conference_question_id"
    t.index ["conference_registration_id", "conference_question_id"], name: "index_conference_answers_on_registration_and_question", unique: true
    t.index ["conference_registration_id"], name: "index_conference_answers_on_conference_registration_id"
  end

  create_table "conference_questions", force: :cascade do |t|
    t.text "choices"
    t.integer "conference_id", null: false
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.integer "position", default: 0, null: false
    t.string "question_type", default: "short_text", null: false
    t.boolean "required", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id", "position"], name: "index_conference_questions_on_conference_id_and_position"
    t.index ["conference_id"], name: "index_conference_questions_on_conference_id"
  end

  create_table "conference_registrations", force: :cascade do |t|
    t.datetime "cancelled_at"
    t.integer "conference_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id", "cancelled_at"], name: "idx_on_conference_id_cancelled_at_55323c382e"
    t.index ["conference_id", "created_at"], name: "index_conference_registrations_on_conference_id_and_created_at"
    t.index ["conference_id"], name: "index_conference_registrations_on_conference_id"
  end

  create_table "conferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at"
    t.string "location"
    t.string "name", null: false
    t.boolean "registration_open", default: false, null: false
    t.string "slug", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_conferences_on_slug", unique: true
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

  create_table "email_suppressions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_email_suppressions_on_email", unique: true
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
    t.boolean "email_consent", default: false, null: false
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
    t.string "provider_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_message_deliveries_on_member_id"
    t.index ["message_id"], name: "index_message_deliveries_on_message_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.integer "captured_count", default: 0, null: false
    t.string "channel", default: "sms", null: false
    t.integer "contact_group_id"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.integer "failed_count", default: 0
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.integer "sent_count", default: 0
    t.integer "skipped_count", default: 0, null: false
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
  add_foreign_key "conference_answers", "conference_questions"
  add_foreign_key "conference_answers", "conference_registrations"
  add_foreign_key "conference_questions", "conferences"
  add_foreign_key "conference_registrations", "conferences"
  add_foreign_key "contact_group_memberships", "contact_groups"
  add_foreign_key "contact_group_memberships", "members"
  add_foreign_key "events", "calendar_sources"
  add_foreign_key "members", "households"
  add_foreign_key "message_deliveries", "members"
  add_foreign_key "message_deliveries", "messages"
  add_foreign_key "messages", "contact_groups"
end
