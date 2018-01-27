class AddVerifyKeyToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :verify_key, :string
  end
end
