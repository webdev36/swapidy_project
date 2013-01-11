class CreateSwapidySettings < ActiveRecord::Migration
  def change
    create_table :swapidy_settings do |t|
      t.string :title
      t.string :value
      t.string :value_type
      t.timestamps
    end
    SwapidySetting.reset_column_information
    SwapidySetting.init_default_titles
  end

end
