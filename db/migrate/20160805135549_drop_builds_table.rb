class DropBuildsTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :builds
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
