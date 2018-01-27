class AddHiddenToDeaths < ActiveRecord::Migration[5.1]
  def change
    add_column :deaths, :user_hidden, :boolean, :default => true
    add_column :deaths, :cause_hidden, :boolean, :default => false
  end
end
