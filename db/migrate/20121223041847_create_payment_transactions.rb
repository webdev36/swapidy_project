class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.integer :user_id
      t.integer :gateway, :default => 0
      t.string :payment_charge_id
      t.string :payment_invoice_id
      t.string :payment_type
      t.string :status
      t.decimal :amount
      t.decimal :honey_money
      t.string :card_name
      t.string :card_type
      t.string :card_expired_month, :limit => 2
      t.string :card_expired_year, :limit => 4
      t.string :card_last_four_number , :limit => 4

      t.timestamps
    end
  end
end
