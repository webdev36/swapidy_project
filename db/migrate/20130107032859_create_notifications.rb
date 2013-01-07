class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :title
      t.string :description 
      t.integer :user_id
      t.integer :notify_object_id
      t.string :notify_object_type
      t.boolean :has_read, :default => false

      t.timestamps
    end
  end
end
