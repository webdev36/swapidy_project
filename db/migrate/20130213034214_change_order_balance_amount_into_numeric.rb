class ChangeOrderBalanceAmountIntoNumeric < ActiveRecord::Migration
  def up
    change_column :users, :balance_amount, :decimal, :precision => 10, :scale => 2
    change_column :payment_transactions, :amount, :decimal, :precision => 10, :scale => 2
    change_column :orders, :balance_amount, :decimal, :precision => 10, :scale => 2
    change_column :order_products, :price, :decimal, :precision => 10, :scale => 2
  end

  def down
    change_column :users, :balance_amount, :decimal
    change_column :payment_transactions, :amount, :decimal
    change_column :orders, :price_for_sell, :integer
    change_column :order_products, :price_for_good_sell, :integer
  end
end
