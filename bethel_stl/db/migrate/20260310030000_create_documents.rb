class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :documentable, polymorphic: true, null: false
      t.string :name

      t.timestamps
    end
  end
end
