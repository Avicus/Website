class IndexApiKeys < ActiveRecord::Migration[5.1]
  def change
      add_index :users, :api_key
    end
end