class AddHoneyBalanceIntoUsers < ActiveRecord::Migration
  def up
    add_column :users, :honey_balance, :decimal, :default => 0
    add_column :orders, :honey_price, :decimal, :default => 0
    add_column :orders, :using_condition, :string
    remove_column :orders, :email
    remove_column :orders, :stripe_email
    remove_column :orders, :stripe_customer_id
  end

  def down
    remove_column :users, :honey_balance
    remove_column :orders, :honey_price
    remove_column :orders, :using_condition
    add_column :orders, :email, :string
    add_column :orders, :stripe_email, :string
    add_column :orders, :stripe_customer_id, :string
  end
end
