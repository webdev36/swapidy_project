class ChangeHoneyToInteger < ActiveRecord::Migration
  def up
    change_column :orders, :honey_price, :integer
    change_column :payment_transactions, :honey_money, :integer
    change_column :products, :honey_price, :integer
    change_column :products, :price_for_good_type, :integer
    change_column :products, :price_for_poor_type, :integer
    change_column :redeem_codes, :honey_amount, :integer
    change_column :free_honeys, :sender_honey_amount, :integer
    change_column :free_honeys, :receiver_honey_amount, :integer
  end

  def down
    change_column :orders, :honey_price, :decimal, :precision => 10, :scale => 2
    change_column :payment_transactions, :honey_money, :decimal, :precision => 10, :scale => 2
    change_column :products, :honey_price, :decimal, :precision => 10, :scale => 2
    change_column :products, :price_for_good_type, :decimal, :precision => 10, :scale => 2
    change_column :products, :price_for_poor_type, :decimal, :precision => 10, :scale => 2
    change_column :redeem_codes, :honey_amount, :decimal, :precision => 10, :scale => 2
    change_column :free_honeys, :sender_honey_amount, :decimal, :precision => 10, :scale => 2
    change_column :free_honeys, :receiver_honey_amount, :decimal, :precision => 10, :scale => 2
  end
end
