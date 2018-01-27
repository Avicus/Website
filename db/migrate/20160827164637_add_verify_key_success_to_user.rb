class AddVerifyKeySuccessToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :verify_key_success, :boolean
  end
end
