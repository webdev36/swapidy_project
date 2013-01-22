class RemovePostsAndComments < ActiveRecord::Migration
  def up
    drop_table :posts
    drop_table :comments
  end
  
  def down
    create_table :posts do |t|
      t.string :name
      t.string :title
      t.text :content

      t.timestamps
    end
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :post

      t.timestamps
    end
  end
end
