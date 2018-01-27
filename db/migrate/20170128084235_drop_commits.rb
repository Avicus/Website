class DropCommits < ActiveRecord::Migration[5.1]
  def change
    drop_table :commits
  end
end
