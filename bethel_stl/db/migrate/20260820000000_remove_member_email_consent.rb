class RemoveMemberEmailConsent < ActiveRecord::Migration[8.1]
  def change
    remove_column :members, :email_consent, :boolean, default: true, null: false
  end
end
