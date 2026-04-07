class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :location
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :all_day, default: false, null: false
      t.boolean :public, default: false, null: false
      t.string :google_event_id
      t.references :calendar_source, null: false, foreign_key: true

      t.timestamps
    end

    add_index :events, :google_event_id
    add_index :events, [:public, :starts_at]
  end
end
