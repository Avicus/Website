class AddIconToServerGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :server_groups, :icon, :string
  end
end
