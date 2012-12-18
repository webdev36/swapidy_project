class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.integer :user_id
      t.integer :category_id
      t.string  :model
      t.string  :memory_style
      t.string  :quality_status
      t.decimal :honey_price

      t.timestamps
    end
  end
end
