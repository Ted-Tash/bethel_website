class AddEmailDeliverySupport < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :email_consent, :boolean, default: false, null: false
    create_table :email_suppressions do |t|
      t.string :email, null: false
      t.timestamps
    end
    add_index :email_suppressions, :email, unique: true
    add_column :message_deliveries, :provider_id, :string
    add_column :messages, :captured_count, :integer, default: 0, null: false
    add_column :messages, :skipped_count, :integer, default: 0, null: false
    add_column :messages, :error_message, :text
  end
end
