class AddShippingZipCodeAddOnIntoOrders < ActiveRecord::Migration
  def up
    add_column :orders, :shipping_zip_code_add_on, :string
  end

  def down
    remove_column :orders, :shipping_zip_code_add_on
  end
end
