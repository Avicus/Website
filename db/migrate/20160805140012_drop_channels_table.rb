class DropChannelsTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :channels
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
