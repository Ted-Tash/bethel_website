class CreateAudioExtractions < ActiveRecord::Migration[8.1]
  def change
    create_table :audio_extractions do |t|
      t.string :youtube_url, null: false
      t.string :start_time
      t.string :end_time
      t.string :status, null: false, default: 'pending'
      t.text :error_message
      t.string :filename
      t.integer :file_size

      t.timestamps
    end
  end
end
