class RemoveTimestampFields < ActiveRecord::Migration
  def up
    remove_column :images, :created_at
    remove_column :images, :updated_at
    remove_column :products, :created_at
    remove_column :products, :updated_at
    remove_column :categories, :created_at
    remove_column :categories, :updated_at
    remove_column :category_attributes, :created_at
    remove_column :category_attributes, :updated_at
    remove_column :product_models, :created_at
    remove_column :product_models, :updated_at
    remove_column :product_model_attributes, :created_at
    remove_column :product_model_attributes, :updated_at
  end

  def down
    add_column :images, :created_at, :datetime
    add_column :images, :updated_at, :datetime
    add_column :products, :created_at, :datetime
    add_column :products, :updated_at, :datetime
    add_column :categories, :created_at, :datetime
    add_column :categories, :updated_at, :datetime
    add_column :product_model_attributes, :created_at, :datetime
    add_column :product_model_attributes, :updated_at, :datetime
    add_column :category_attributes, :created_at, :datetime
    add_column :category_attributes, :updated_at, :datetime
    add_column :product_models, :created_at, :datetime
    add_column :product_models, :updated_at, :datetime
  end

end
