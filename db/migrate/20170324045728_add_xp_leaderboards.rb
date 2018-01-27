class AddXpLeaderboards < ActiveRecord::Migration[5.1]
  def change
    create_table :experience_leaderboard_entries do |t|
      t.references :user, index: true
      t.integer :period
      t.integer :level
      t.integer :prestige_level
      t.integer :xp_total
      t.integer :xp_nebula
      t.integer :xp_koth
      t.integer :xp_ctf
      t.integer :xp_tdm
      t.integer :xp_elimination
      t.integer :xp_sw
      t.integer :xp_walls
      t.integer :xp_arcade

      t.timestamps
    end

    add_column :experience_transactions, :genre, :string
  end
end
