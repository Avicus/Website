class AddDataToServerGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :server_groups, :data, :text
  end
end
