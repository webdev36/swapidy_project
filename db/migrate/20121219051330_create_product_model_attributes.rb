class CreateProductModelAttributes < ActiveRecord::Migration
  def change
    create_table :product_model_attributes do |t|
      t.integer :product_model_id
      t.integer :category_attribute_id
      t.string :value
      t.timestamps
    end
    if Rails.env == 'production'
      add_index :product_model_attributes, [:product_model_id]
      add_index :product_model_attributes, [:category_attribute_id]
    end
  end
end
