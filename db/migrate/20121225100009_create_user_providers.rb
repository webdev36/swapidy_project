class CreateUserProviders < ActiveRecord::Migration
  def change
    create_table :user_providers do |t|
      t.string :provider
      t.string :uid
      t.string :access_token
      t.datetime :token_expires_at
      t.references :user

      t.timestamps
    end
    
    add_column :users, :provider_image, :string
  end
end
