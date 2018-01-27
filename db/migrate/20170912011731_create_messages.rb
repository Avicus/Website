class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.references :sender
      t.references :receiver
      t.text :content

      t.timestamps
    end
  end
end
