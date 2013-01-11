class AddTitleIntoOrders < ActiveRecord::Migration
  def up
    add_column :orders, :product_title, :string
    Order.reset_column_information
    Order.all.each do |order|
      order.generate_product_title
      order.save
    end
  end

  def down
    remove_column :orders, :product_title
  end
end
