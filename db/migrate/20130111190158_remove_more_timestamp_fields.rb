class RemoveMoreTimestampFields < ActiveRecord::Migration
  def up
    remove_column :product_attributes, :created_at
    remove_column :product_attributes, :updated_at
    remove_column :swapidy_settings, :created_at
    remove_column :swapidy_settings, :updated_at
  end

  def down
    add_column :swapidy_settings, :created_at, :datetime
    add_column :swapidy_settings, :updated_at, :datetime
    add_column :product_attributes, :created_at, :datetime
    add_column :product_attributes, :updated_at, :datetime
  end
end
