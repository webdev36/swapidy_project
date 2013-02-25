class SetLongContentInBrandEmails < ActiveRecord::Migration
  def up
    change_column :brand_emails, :content, :string, :limit => 2000
  end

  def down
    change_column :brand_emails, :content, :string, :limit => nil
  end
end
