class AddCancelledAtToConferenceRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :conference_registrations, :cancelled_at, :datetime
    add_index :conference_registrations, [ :conference_id, :cancelled_at ]
  end
end
