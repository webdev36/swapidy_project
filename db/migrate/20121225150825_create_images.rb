class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :for_object_id
      t.string  :for_object_type
      t.string  :sum_attribute_names
      t.string  :photo_file_name
      t.string  :photo_content_type
      t.integer :photo_file_size
      t.string  :title
      t.boolean :is_main, :default => false
      t.timestamps
    end
    
    remove_columns :products, :image_file_name
    remove_columns :products, :image_content_type
    remove_columns :products, :image_file_size
    
    remove_columns :categories, :image_file_name
    remove_columns :categories, :image_content_type
    remove_columns :categories, :image_file_size
    
    remove_columns :product_models, :image_file_name
    remove_columns :product_models, :image_content_type
    remove_columns :product_models, :image_file_size
  end

end
