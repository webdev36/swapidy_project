class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :product_id
      t.integer :order_type
      t.integer :user_id
      #t.string  :title
      #t.decimal :honey_price
      #t.string  :using_condition
      t.integer :status
      t.timestamps
    end
  end
end
