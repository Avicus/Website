class DropMinigamesTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :minigames
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
