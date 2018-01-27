class ModifySubscriptions < ActiveRecord::Migration[5.1]
  def change
    rename_column :subscriptions, :discussion_id, :post_id
  end
end
