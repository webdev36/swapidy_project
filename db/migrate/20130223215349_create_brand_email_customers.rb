class CreateBrandEmailCustomers < ActiveRecord::Migration
  def change
    create_table :brand_email_customers do |t|
      t.integer :user_id
      t.string :email
      t.integer :brand_email_id
      t.integer :status, :default => 0 #has created and sending
      t.timestamps
    end
  end
end
