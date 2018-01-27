class AddDiscordToUserDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :user_details, :discord, :string
  end
end
