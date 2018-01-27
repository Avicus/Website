class DropOldTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :counts
    drop_table :logs
    drop_table :polls
    drop_table :post_reactions # rip the dream
    drop_table :post_versions
    drop_table :posts
    drop_table :products
    drop_table :reviews
    drop_table :statistics
    drop_table :tickets
    drop_table :tags
  end
end
