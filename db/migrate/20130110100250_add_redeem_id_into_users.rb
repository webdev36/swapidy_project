class AddRedeemIdIntoUsers < ActiveRecord::Migration
  def up
    add_column :users, :redeem_code_id, :integer
    remove_column :redeem_codes, :user_id
  end

  def down
    remove_column :users, :redeem_code_id
    add_column :redeem_codes, :user_id, :integer
  end
end
