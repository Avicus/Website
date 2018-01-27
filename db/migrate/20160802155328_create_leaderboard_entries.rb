class CreateLeaderboardEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :leaderboard_entries do |t|
      t.references :user, index: true
      t.integer :period
      t.integer :kills
      t.integer :deaths
      t.float :kd_ratio
      t.integer :monuments
      t.integer :wools
      t.integer :flags
      t.integer :hills
      t.integer :score
      t.integer :time_online

      t.timestamps
    end
  end
end
