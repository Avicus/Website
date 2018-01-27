class CreateServerGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :server_groups do |t|
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end
  end
end
