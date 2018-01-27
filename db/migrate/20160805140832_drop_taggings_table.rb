class DropTaggingsTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :taggings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
