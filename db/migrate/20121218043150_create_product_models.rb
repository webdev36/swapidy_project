class CreateProductModels < ActiveRecord::Migration
  def change
    create_table :product_models do |t|
      t.string :title
      t.integer :product_id
      t.string :memory_space
      t.string :comment

      t.timestamps
    end
  end
end
