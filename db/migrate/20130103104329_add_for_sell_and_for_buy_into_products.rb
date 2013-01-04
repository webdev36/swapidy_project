class AddForSellAndForBuyIntoProducts < ActiveRecord::Migration
  def up
    add_column :products, :for_buy, :boolean, :default => true
    add_column :products, :for_sell, :boolean, :default => true
    Product.reset_column_information
    Product.where("using_condition != ?", Product::USING_CONDITIONS[:flawless]).each do |product|
      product.update_attribute(:for_buy, false)
    end
  end

  def down
    remove_column :products, :for_buy
    remove_column :products, :for_sell
  end
end
