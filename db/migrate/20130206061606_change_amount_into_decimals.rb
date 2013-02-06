class ChangeAmountIntoDecimals < ActiveRecord::Migration

  def up
    change_column :products, :price_for_sell, :decimal, :precision => 10, :scale => 2
    change_column :products, :price_for_good_sell, :decimal, :precision => 10, :scale => 2
    change_column :products, :price_for_poor_sell, :decimal, :precision => 10, :scale => 2
    change_column :products, :price_for_buy, :decimal, :precision => 10, :scale => 2
    change_column :products, :price_for_good_buy, :decimal, :precision => 10, :scale => 2
    change_column :products, :price_for_poor_buy, :decimal, :precision => 10, :scale => 2
    change_column :redeem_codes, :amount, :decimal, :precision => 10, :scale => 2
    change_column :free_honeys, :sender_amount, :decimal, :precision => 10, :scale => 2
    change_column :free_honeys, :receiver_amount, :decimal, :precision => 10, :scale => 2
  end

  def down
    change_column :products, :price_for_sell, :integer
    change_column :products, :price_for_good_sell, :integer
    change_column :products, :price_for_poor_sell, :integer
    change_column :products, :price_for_buy, :integer
    change_column :products, :price_for_good_buy, :integer
    change_column :products, :price_for_poor_buy, :integer
    change_column :redeem_codes, :honey_amount, :integer
    change_column :free_honeys, :sender_honey_amount, :integer
    change_column :free_honeys, :receiver_honey_amount, :integer
  end
end
