class DropDeploysTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :deploys
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
