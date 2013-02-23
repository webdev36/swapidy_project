class AddSortNumberIntoTables < ActiveRecord::Migration
  def up
    add_column :categories, :sort_number, :integer
    add_column :product_models, :sort_number, :integer
  end

  def down
    remove_column :categories, :sort_number
    remove_column :product_models, :sort_number
  end
end
