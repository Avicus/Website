class CreateServerCategories < ActiveRecord::Migration[5.1]
  def change
    drop_table :server_categories

    create_table :server_categories do |t|
      t.string :name
      t.text :communication_options
      t.text :tracking_options
      t.text :infraction_options
    end
  end
end
