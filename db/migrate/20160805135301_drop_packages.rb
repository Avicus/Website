class DropPackages < ActiveRecord::Migration[5.1]
  def up
    drop_table :packages
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
