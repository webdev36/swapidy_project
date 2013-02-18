class MergeSellBuyTypeIntoProducts < ActiveRecord::Migration
  def up
    add_column :products, :swap_type, :integer, :default => 0 #sell and buy
    Product.reset_column_information
    Product.where("for_buy = true").each do |product|
      product.price_for_buy = product.price_for_sell
      product.price_for_good_buy = product.price_for_good_sell
      product.price_for_poor_buy = product.price_for_poor_sell
      product.price_for_sell = nil
      product.price_for_good_sell = nil
      product.price_for_poor_sell = nil
      product.save
    end
    Product.where("for_sell = true").each do |product|
      product.swap_type = (product.for_buys? && product.for_sells?) ? 0 : (product.for_sells? ? 1 : 2)
      product.save
    end
    remove_column :products, :for_sell
    remove_column :products, :for_buy
  end

  def down
    add_column :products, :for_buy, :boolean, :default => false
    add_column :products, :for_sell, :boolean, :default => false
    remove_column :products, :swap_type
  end
end
