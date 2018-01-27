class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts, :options => 'COLLATE=utf8_general_ci' do |t|
      t.string :uuid, index: true
      t.references :author, index: true
      t.references :version_author, index: true
      t.references :ancestor, index: true
      t.references :parent, index: true
      t.string :ancestor_type
      t.references :category, index: true
      t.string :name
      t.text :body
      t.boolean :stickied, :default => false
      t.boolean :archived, :default => false
      t.boolean :deleted, :default => false
      t.boolean :locked, :default => false

      t.timestamps
    end
  end
end
