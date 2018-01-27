class AddSanctionedToReplies < ActiveRecord::Migration[5.1]
  def change
    add_column :revisions, :sanctioned, :boolean, default: false
  end
end
