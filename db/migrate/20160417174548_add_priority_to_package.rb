class AddPriorityToPackage < ActiveRecord::Migration[5.1]
  def change
    add_column :packages, :priority, :integer
  end
end
