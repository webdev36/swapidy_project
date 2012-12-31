class ExtendUrlFieldLength < ActiveRecord::Migration
  def up
    change_column :shipping_stamps, :url, :string, :limit => 1000
  end

  def down
    change_column :shipping_stamps, :url, :string, :limit => nil
  end
end
