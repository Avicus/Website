class AddHiddenToObjectives < ActiveRecord::Migration[5.1]
  def change
    add_column :objectives, :hidden, :boolean, :default => false
  end
end
