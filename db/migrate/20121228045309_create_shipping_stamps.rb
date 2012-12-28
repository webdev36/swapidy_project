class CreateShippingStamps < ActiveRecord::Migration
  def change
    create_table :shipping_stamps do |t|
      t.integer :order_id
      t.string  :integrator_tx_id
      t.string  :tracking_number
      t.string  :service_type
      t.string  :rate_amount
      t.string  :package_type
      t.datetime :due_date
      t.string  :stamps_tx_id
      t.string  :url
      t.string  :status
      t.timestamps
    end
  end
end