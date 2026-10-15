class CreateConferenceAdmins < ActiveRecord::Migration[8.1]
  def change
    create_table :conference_admins do |t|
      t.references :conference, null: false, foreign_key: true
      t.string :email, null: false

      t.timestamps
    end
    add_index :conference_admins, [ :conference_id, :email ], unique: true
  end
end
