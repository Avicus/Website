class CreatePackages < ActiveRecord::Migration[5.1]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :price
      t.string :image_url
      t.string :price_display
      t.text :details

      t.timestamps
    end
  end
end
