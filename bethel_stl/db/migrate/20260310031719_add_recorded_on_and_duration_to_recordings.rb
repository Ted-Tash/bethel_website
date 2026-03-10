class AddRecordedOnAndDurationToRecordings < ActiveRecord::Migration[8.1]
  def change
    add_column :recordings, :recorded_on, :date
    add_column :recordings, :duration_seconds, :integer
  end
end
