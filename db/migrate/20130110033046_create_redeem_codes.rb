class CreateRedeemCodes < ActiveRecord::Migration
  def change
    create_table :redeem_codes do |t|
      t.string :code
      t.decimal :honey_amount
      t.integer :user_id
      t.datetime :expired_date
      t.string :status
      t.timestamps
    end
  end
end
