class MergeSellBuyTypeIntoProducts < ActiveRecord::Migration
  def up
    add_column :products, :swap_type, :integer, :default => 0 #sell and buy
    remove_column :products, :for_sell
    remove_column :products, :for_buy
    Product.reset_column_information
    Product.all.each do |product|
      has_sell_prices = product.has_flawless_sell? || product.has_good_sell? || product.has_poor_sell?
      has_buy_prices = product.has_flawless_buy? || product.has_good_buy? || product.has_poor_buy?
      product.update_attribute(:swap_type, has_sell_prices ? 1 : 2) unless has_sell_prices && has_buy_prices
    end
  end

  def down
    add_column :products, :for_buy, :boolean, :default => false
    add_column :products, :for_sell, :boolean, :default => false
    remove_column :products, :swap_type
  end
end
