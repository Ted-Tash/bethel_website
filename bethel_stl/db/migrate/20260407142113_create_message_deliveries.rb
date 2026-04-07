class CreateMessageDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :message_deliveries do |t|
      t.references :message, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.string :phone_or_email
      t.string :status, null: false, default: "pending"
      t.text :error_message
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
