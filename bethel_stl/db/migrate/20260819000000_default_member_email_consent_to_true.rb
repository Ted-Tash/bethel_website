class DefaultMemberEmailConsentToTrue < ActiveRecord::Migration[8.1]
  def change
    change_column_default :members, :email_consent, from: false, to: true
  end
end
