class AddRolesToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :role, :string, null: false, default: "conference_manager"

    # Preserve full access for every existing account, including non-admin users.
    execute "UPDATE users SET role = 'super_admin'"

    add_check_constraint :users, "role IN ('super_admin', 'conference_manager')", name: "users_role_allowed"
    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, null: false, default: false
    execute "UPDATE users SET admin = 1 WHERE role = 'super_admin'"
    remove_check_constraint :users, name: "users_role_allowed"
    remove_column :users, :role
  end
end
