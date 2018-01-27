class CreateServerGroupMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :server_group_members do |t|
      t.references :server_group, index: true
      t.references :server, index: true

      t.timestamps
    end
  end
end
