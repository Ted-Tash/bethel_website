class CreateContactGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_groups do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
