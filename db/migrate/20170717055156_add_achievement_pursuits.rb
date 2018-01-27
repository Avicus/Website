class AddAchievementPursuits < ActiveRecord::Migration[5.1]
  def change
    create_table :achievement_pursuits do |t|
      t.string :slug
      t.integer :progress
      t.references :user, index: true
    end
  end
end
