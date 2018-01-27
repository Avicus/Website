class AddInstagramToUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :user_details, :instagram, :string, :limit => 32
  end
end
