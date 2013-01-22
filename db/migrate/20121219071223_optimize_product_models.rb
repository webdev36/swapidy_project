class OptimizeProductModels < ActiveRecord::Migration
  def up
    remove_column :products, :memory_style
    remove_column :products, :quality_status
    remove_column :products, :model
    
    remove_column :product_models, :memory_space
    remove_column :product_models, :product_id
    add_column :product_models, :category_id, :integer
    
    add_column :products, :using_condition, :string
    add_column :products, :product_model_id, :integer
    add_column :products, :image_file_name, :string # Original filename
    add_column :products, :image_content_type, :string # Mime type
    add_column :products, :image_file_size, :integer # File size in bytes

    drop_table :product_prices
    if Rails.env == 'production'
      add_index :product_models, [:category_id]
      add_index :products, [:category_id]
      add_index :products, [:product_model_id]
    end
  end

  def down
    create_table :product_prices do |t|
      t.string :quality_status
      t.integer :product_model_id
      t.decimal :honey_price
      t.timestamps
    end
    
    remove_column :products, :using_condition
    remove_column :products, :product_model_id
    remove_column :products, :image_file_name
    remove_column :products, :image_content_type
    remove_column :products, :image_file_size
    
    add_column :product_models, :memory_space, :string
    add_column :product_models, :product_id, :integer
    remove_column :product_models, :category_id
    
    add_column :products, :model, :string
    add_column :products, :memory_style, :string
    add_column :products, :quality_status, :string
    
    if Rails.env == 'production'
      remove_index :product_models, [:category_id] rescue nil
      remove_index :products, [:category_id] rescue nil
      remove_index :products, [:product_model_id] rescue nil
    end
  end
end
