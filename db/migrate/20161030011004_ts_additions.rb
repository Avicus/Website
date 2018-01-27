class TsAdditions < ActiveRecord::Migration[5.1]
  def change
    create_table :teamspeak_users do |t|
      t.integer :user_id, :null => false
      t.integer :client_id, :null => false
    end
  end
end
