class CreateCategoryAttributes < ActiveRecord::Migration
  def change
    create_table :category_attributes do |t|
      t.integer :category_id
      t.string  :attribute_type
      t.string  :title
      t.timestamps
    end
    if Rails.env == 'production'
      add_index :category_attributes, [:category_id]
    end
  end
end
