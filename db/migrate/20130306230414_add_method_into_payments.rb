class AddMethodIntoPayments < ActiveRecord::Migration
  def up
    add_column :payment_transactions, :method, :string, :is_null => false, :default => "direct"
    add_column :payment_transactions, :order_id, :integer
  end

  def down
    remove_column :payment_transactions, :method
    remove_column :payment_transactions, :order_id
  end
end
