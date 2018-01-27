class AddHiddenIndices < ActiveRecord::Migration[5.1]
  def change
    add_index :objectives, :hidden
    add_index :deaths, :user_hidden
    add_index :deaths, :cause_hidden
  end
end
