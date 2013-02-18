class AddPricesForBuyingIntoProducts < ActiveRecord::Migration
  def up
    rename_column :products, :honey_price, :price_for_sell
    rename_column :products, :price_for_good_type, :price_for_good_sell
    rename_column :products, :price_for_poor_type, :price_for_poor_sell
    add_column :products, :price_for_buy, :integer
    add_column :products, :price_for_good_buy, :integer
    add_column :products, :price_for_poor_buy, :integer

    #begin
    #  Product.reset_column_information
    #  Product.where("for_buy = true").each do |product|
    #    product.price_for_buy = product.price_for_sell
    #    product.price_for_sell = nil
    #    product.save
    #  end
    #rescue Exception => e
    #end
  end

  def down
    #begin
    #  Product.reset_column_information
    #  Product.where(:for_buy => true).each do |product|
    #    product.price_for_sell = product.price_for_buy 
    #    product.save
    #  end
    #rescue Exception => e
    #end

    rename_column :products, :price_for_sell, :honey_price
    rename_column :products, :price_for_good_sell, :price_for_good_type
    rename_column :products, :price_for_poor_sell, :price_for_poor_type
    remove_column :products, :price_for_buy
    remove_column :products, :price_for_good_buy
    remove_column :products, :price_for_poor_buy
  end
end
