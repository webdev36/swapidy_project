class AddImagesIntoCategoriesAndProducts < ActiveRecord::Migration
  def up
    
    add_column :categories, :image_file_name, :string # Original filename
    add_column :categories, :image_content_type, :string # Mime type
    add_column :categories, :image_file_size, :integer # File size in bytes
    
    add_column :product_models, :image_file_name, :string # Original filename
    add_column :product_models, :image_content_type, :string # Mime type
    add_column :product_models, :image_file_size, :integer # File size in bytes
    
    add_column :product_prices, :image_file_name, :string # Original filename
    add_column :product_prices, :image_content_type, :string # Mime type
    add_column :product_prices, :image_file_size, :integer # File size in bytes
  end

  def down
  end
end
