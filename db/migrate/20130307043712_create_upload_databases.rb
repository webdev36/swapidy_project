class CreateUploadDatabases < ActiveRecord::Migration
  def up
    create_table :upload_databases do |t|
      t.text :data_content
      t.string :product_type
      t.timestamps
    end
    add_column :products, :upload_database_id,:integer
  end
  def down
    drop_table :upload_databases
    remove_column :products,:upload_database_id
  end
end
