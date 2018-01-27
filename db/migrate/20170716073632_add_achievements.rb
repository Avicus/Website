class AddAchievements < ActiveRecord::Migration[5.1]
  def change
    create_table :achievements do |t|
      t.string :slug
      t.string :name
      t.string :description
    end
    create_table :achievement_receivers do |t|
      t.references :user, index: true
      t.references :achievement, index: true
    end
  end
end
