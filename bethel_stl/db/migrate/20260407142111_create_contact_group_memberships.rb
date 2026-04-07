class CreateContactGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_group_memberships do |t|
      t.references :contact_group, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true

      t.timestamps
    end

    add_index :contact_group_memberships, [:contact_group_id, :member_id], unique: true, name: "index_contact_group_memberships_uniqueness"
  end
end
