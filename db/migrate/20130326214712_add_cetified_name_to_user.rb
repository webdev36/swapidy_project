class AddCetifiedNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :certified_name, :string
  end
end
