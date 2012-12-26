class AddIsAdminIntoUsers < ActiveRecord::Migration
  def up
    add_column :users, :is_admin, :boolean, :default => false
    User.reset_column_information
    admin = User.find_by_email "admin@admin.com"
    admin.update_attribute(:is_admin, true) if admin
  end

  def down
    remove_column :users, :is_admin
  end
end
