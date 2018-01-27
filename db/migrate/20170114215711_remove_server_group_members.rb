class RemoveServerGroupMembers < ActiveRecord::Migration[5.1]
  def change
    drop_table :server_group_members
    add_column :servers, :server_group_id, :integer
    add_column :servers, :server_category_id, :integer
  end
end
