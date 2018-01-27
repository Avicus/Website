class CreateServerBoosters < ActiveRecord::Migration[5.1]
  def change
    create_table :server_boosters do |t|
      t.references :user, index: true
      t.references :server, index: true
      t.decimal :multiplier
      t.datetime :starts_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
