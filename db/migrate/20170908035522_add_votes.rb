class AddVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :votes do |t|
      t.references :user, index: true
      t.string :service

      t.datetime :cast_at
    end
  end
end
