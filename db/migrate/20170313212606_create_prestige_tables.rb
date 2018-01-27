class CreatePrestigeTables < ActiveRecord::Migration[5.1]
  def change
    create_table :prestige_seasons do |t|
      t.string :name
      t.string :multiplier
      t.datetime :start_at
      t.datetime :end_at
    end

    create_table :prestige_levels do |t|
      t.integer :user_id
      t.integer :season_id
      t.integer :level
    end

    create_table :experience_transactions do |t|
      t.integer :user_id
      t.integer :season_id
      t.integer :amount

      t.timestamps
    end
  end
end
