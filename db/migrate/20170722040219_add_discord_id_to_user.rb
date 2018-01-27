class AddDiscordIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :discord_id, :bigint
  end
end
