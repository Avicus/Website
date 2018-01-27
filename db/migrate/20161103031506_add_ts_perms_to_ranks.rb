class AddTsPermsToRanks < ActiveRecord::Migration[5.1]
  def change
    add_column :ranks, :ts_perms, :text
  end
end
