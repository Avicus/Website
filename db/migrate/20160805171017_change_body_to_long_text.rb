class ChangeBodyToLongText < ActiveRecord::Migration[5.1]
  def up
    change_column :posts, :body, :text, :limit => 16.megabytes - 1
  end
end
