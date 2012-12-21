class AddShippingFieldsIntoOrders < ActiveRecord::Migration
  def up
    add_column :orders, :email, :string
    add_column :orders, :stripe_email, :string
    add_column :orders, :stripe_customer_id, :string
    add_column :orders, :shipping_method, :string
    add_column :orders, :shipping_first_name, :string
    add_column :orders, :shipping_last_name, :string
    add_column :orders, :shipping_address, :string
    add_column :orders, :shipping_optional_address, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_state, :string
    add_column :orders, :shipping_zip_code, :string
    add_column :orders, :shipping_country, :string
  end

  def down
    remove_column :orders, :email
    remove_column :orders, :stripe_email
    remove_column :orders, :stripe_customer_id
    remove_column :orders, :shipping_method
    remove_column :orders, :shipping_first_name
    remove_column :orders, :shipping_last_name
    remove_column :orders, :shipping_address
    remove_column :orders, :shipping_optional_address
    remove_column :orders, :shipping_city
    remove_column :orders, :shipping_state
    remove_column :orders, :shipping_zip_code
    remove_column :orders, :shipping_country
  end
end
