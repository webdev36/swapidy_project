class CreateLocationVotes < ActiveRecord::Migration
  def change
    create_table :location_votes do |t|
      t.integer  :user_id
      t.string  :user_ip
      t.string   :location

      t.timestamps
    end
  end
end
