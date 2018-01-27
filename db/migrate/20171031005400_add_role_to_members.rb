class AddRoleToMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :memberships, :role, :string
  end
end
