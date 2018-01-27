class CreatePostReactions < ActiveRecord::Migration[5.1]
  def change
    create_table :post_reactions do |t|
      t.references :post, index: true
      t.references :user, index: true
      t.string :emoji

      t.timestamps
    end
  end
end
