class CreateConferenceRegistrationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :conferences do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :location
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :registration_open, null: false, default: false

      t.timestamps
    end
    add_index :conferences, :slug, unique: true

    create_table :conference_questions do |t|
      t.references :conference, null: false, foreign_key: true
      t.string :label, null: false
      t.string :question_type, null: false, default: "short_text"
      t.text :choices
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :conference_questions, [ :conference_id, :position ]

    create_table :conference_registrations do |t|
      t.references :conference, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone, null: false

      t.timestamps
    end
    add_index :conference_registrations, [ :conference_id, :created_at ]

    create_table :conference_answers do |t|
      t.references :conference_registration, null: false, foreign_key: true
      t.references :conference_question, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end
    add_index :conference_answers,
      [ :conference_registration_id, :conference_question_id ],
      unique: true,
      name: "index_conference_answers_on_registration_and_question"
  end
end
