class CreateOrderProducts < ActiveRecord::Migration
  def change
    create_table :order_products do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :price
      t.string :using_condition, :default => "Flawless"
      t.string :sell_or_buy, :default => "buy"

      t.timestamps
    end

    begin
      OrderProduct.reset_column_information
      Order.all.each do |order|
        order.order_products.create(:product_id => order.product_id, 
                                    :sell_or_buy => order.order_type && order.order_type == 1 ? "buy" : "sell",
                                    :price => order.honey_price,
                                    :using_condition => order.honey_price)
      end
    rescue Exception => e
    end
  end
end
