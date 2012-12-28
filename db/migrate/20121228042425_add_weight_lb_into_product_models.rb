class AddWeightLbIntoProductModels < ActiveRecord::Migration
  def up
    add_column :product_models, :weight_lb, :decimal, :default => 1.0
    add_column :orders, :weight_lb, :decimal, :default => 1.0
    
    Order.reset_column_information
    ProductModel.reset_column_information
    ipad = Category.find_by_title "iPad"
    if ipad
      ipad.product_models.each {|m| m.update_attribute(:weight_lb, 2.0) }
    end
    
    macbook = Category.find_by_title "Macbook"
    if macbook
      mac_pro_model = macbook.product_models.find_by_title "Macbook Pro"
      mac_pro_model.update_attribute(:weight_lb, 8.0)
      
      mac_model = macbook.product_models.find_by_title "Macbook"
      mac_model.update_attribute(:weight_lb, 8.0)
      
      mac_air_model = macbook.product_models.find_by_title "Macbook Air"
      mac_air_model.update_attribute(:weight_lb, 5.0)
    end
  end

  def down
    remove_column :product_models, :weight_lb
    remove_column :orders, :weight_lb
  end
end
