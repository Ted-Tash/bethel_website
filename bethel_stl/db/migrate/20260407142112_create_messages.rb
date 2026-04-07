class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.text :body, null: false
      t.string :channel, null: false, default: "sms"
      t.datetime :scheduled_at
      t.string :status, null: false, default: "scheduled"
      t.references :contact_group, foreign_key: true
      t.datetime :sent_at
      t.integer :sent_count, default: 0
      t.integer :failed_count, default: 0
      t.string :subject

      t.timestamps
    end
  end
end
