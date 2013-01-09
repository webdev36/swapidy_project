class CreateFreeHoneys < ActiveRecord::Migration
  def change
    create_table :free_honeys do |t|
      t.integer   :sender_id
      t.integer   :receiver_id
      t.string    :receiver_email
      t.decimal   :sender_honey_amount
      t.decimal   :receiver_honey_amount
      t.string    :token_key
      t.datetime  :expired_date
      t.integer   :status
      t.datetime  :completed_at

      t.timestamps
    end
  end
end
