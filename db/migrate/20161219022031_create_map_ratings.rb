class CreateMapRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :map_ratings do |t|
      t.string :map_name
      t.string :map_version
      t.integer :player
      t.integer :rating
      t.string :feedback

      t.timestamps
    end
  end
end
