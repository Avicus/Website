class FixDefaultHiddenInDeaths < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:deaths, :user_hidden, false)
  end
end
