class CreateProductPrices < ActiveRecord::Migration
  def change
    create_table :product_prices do |t|
      t.string :quality_status
      t.integer :product_model_id
      t.decimal :honey_price

      t.timestamps
    end
  end
end
