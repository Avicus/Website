class AddLastReplyAtToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :last_reply_at, :datetime
  end
end
