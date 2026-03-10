class CreateRecordings < ActiveRecord::Migration[8.1]
  def change
    create_table :recordings do |t|
      t.string :title, null: false
      t.string :speaker_name, null: false

      t.timestamps
    end
  end
end
