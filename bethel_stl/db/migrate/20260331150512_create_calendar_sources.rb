class CreateCalendarSources < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_sources do |t|
      t.string :name
      t.string :google_calendar_id

      t.timestamps
    end
  end
end
