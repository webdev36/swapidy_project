class RemoveUnnessesaryFields < ActiveRecord::Migration
  def up
    add_column :order_products, :product_title, :string
    add_column :order_products, :weight_lb, :decimal, :default => 1.0
    remove_column :orders, :order_type
    remove_column :orders, :weight_lb
    remove_column :orders, :product_title
    remove_column :payment_transactions, :honey_money
    
    rename_column :orders, :honey_price, :balance_amount
    rename_column :users, :honey_balance, :balance_amount
    rename_column :redeem_codes, :honey_amount, :amount
    rename_column :free_honeys, :sender_honey_amount, :sender_amount
    rename_column :free_honeys, :receiver_honey_amount, :receiver_amount
  end

  def down
    remove_column :order_products, :product_title
    remove_column :order_products, :weight_lb
    add_column :orders, :order_type, :integer
    add_column :orders, :weight_lb, :decimal, :default => 1.0
    add_column :orders, :product_title, :string
    add_column :payment_transactions, :honey_money, :integer

    rename_column :orders, :balance_amount, :honey_price
    rename_column :users, :balance_amount, :honey_balance
    
    rename_column :redeem_codes, :amount, :honey_amount
    rename_column :free_honeys, :sender_amount, :sender_honey_amount
    rename_column :free_honeys, :receiver_amount, :receiver_honey_amount
  end
end
