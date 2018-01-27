class FixSubscriptions < ActiveRecord::Migration[5.1]
  def change
    rename_column :subscriptions, :post_id, :discussion_id
  end
end
