class CreateProductAttributes < ActiveRecord::Migration
  def change
    create_table :product_attributes do |t|
      t.integer :product_id
      t.integer :product_model_attribute_id
      t.string :value

      t.timestamps
    end
    if Rails.env == 'production'
      add_index :product_attributes, [:product_model_attribute_id]
    end
  end
end
