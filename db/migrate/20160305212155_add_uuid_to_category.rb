class AddUuidToCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :uuid, :string
  end
end
