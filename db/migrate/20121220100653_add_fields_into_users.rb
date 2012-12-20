class AddFieldsIntoUsers < ActiveRecord::Migration
  def up

    add_column :users, :card_type, :string
    add_column :users, :card_name, :string
    add_column :users, :card_expired_month, :string, :limit => 2
    add_column :users, :card_expired_year, :string, :limit => 4
    add_column :users, :card_postal_code, :string
    add_column :users, :address, :string
    
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_card_token, :string
    add_column :users, :card_last_four_number, :string
    add_column :users, :stripe_coupon, :string
    add_column :users, :stripe_customer_card_token, :string
    
  end

  def down
    remove_column :users, :card_type
    remove_column :users, :card_name
    remove_column :users, :card_expired_month
    remove_column :users, :card_expired_year
    remove_column :users, :card_postal_code
    remove_column :users, :address
    
    remove_column :users, :stripe_customer_id
    remove_column :users, :stripe_card_token
    remove_column :users, :card_last_four_number
    remove_column :users, :stripe_coupon
    remove_column :users, :stripe_customer_card_token
  end

end
