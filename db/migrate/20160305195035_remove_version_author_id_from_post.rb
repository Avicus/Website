class RemoveVersionAuthorIdFromPost < ActiveRecord::Migration[5.1]
  def change
    remove_column :posts, :version_author_id
  end
end
