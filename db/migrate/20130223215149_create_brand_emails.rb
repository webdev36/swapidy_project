class CreateBrandEmails < ActiveRecord::Migration
  def change
    create_table :brand_emails do |t|
      t.string :title
      t.string :content
      t.timestamps
    end
  end
end
