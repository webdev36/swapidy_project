class AddPricesIntoProducts < ActiveRecord::Migration
  def up
    add_column :products, :price_for_good_type, :decimal
    add_column :products, :price_for_poor_type, :decimal
    
#    Product.reset_column_information
#    Product.where(:using_condition => "Flawless").each do |product|
#      main_title = product.title.delete("(Flawless)").strip
#      
#      good_product = Product.find_by_title("#{main_title} (Good)")
#      if good_product
#        product.update_attribute(:price_for_good_type, good_product.honey_price)
#        good_product.destroy
#      end
#
#      poor_product = Product.find_by_title("#{main_title} (Poor)")
#      if poor_product
#        product.update_attribute(:price_for_poor_type, poor_product.honey_price)
#        poor_product.destroy
#      end
#    end
    remove_column :products, :using_condition
  end

  def down
    add_column :products, :using_condition, :string
    
#    Product.reset_column_information
#    Product.all.each do |product|
#      if product.price_for_good_type && product.price_for_good_type > 0
#        good_product = Product.new(:title => "#{product.title} (Good)", :honey_price => product.price_for_good_type, :using_condition => "Good")
#        good_product.category = product.category
#        good_product.product_model = product.product_model
#        good_product.save
#        product.product_model_attributes.each do |attr|
#          product_attr = good_product.product_attributes.new
#          product_attr.product_model_attribute = attr
#          product_attr.save
#        end
#      end
#     
#      if product.price_for_poor_type && product.price_for_poor_type > 0
#        poor_product = Product.new(:title => "#{product.title} (Poor)", :honey_price => product.price_for_poor_type, :using_condition => "Poor")
#        poor_product.category = product.category
#        poor_product.product_model = product.product_model
#        poor_product.save
#        product.product_model_attributes.each do |attr|
#          product_attr = poor_product.product_attributes.new
#          product_attr.product_model_attribute = attr
#          product_attr.save
#        end
#      end
#      product.title = "#{product.title} (Flawless)"
#      product.using_codition = "Flawless"
#      product.save
#    end

    remove_column :products, :price_for_good_type
    remove_column :products, :price_for_poor_type
  end

end
