class AddPresents < ActiveRecord::Migration[5.1]
  def change
    create_table :presents do |t|
      t.string :slug
      t.string :family
      t.string :human_name
      t.string :human_location

      t.datetime :found_at
    end

    create_table :present_finders do |t|
      t.references :user, index: true
      t.references :present, index: true
    end
  end
end
