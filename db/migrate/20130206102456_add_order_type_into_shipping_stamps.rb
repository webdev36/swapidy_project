class AddOrderTypeIntoShippingStamps < ActiveRecord::Migration

  def up
    add_column :shipping_stamps, :sell_or_buy, :string, :default => "sell"
  end

  def down
    remove_column :shipping_stamps, :sell_or_buy
  end

end
