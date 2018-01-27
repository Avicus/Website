class AddIpBans < ActiveRecord::Migration[5.1]
  def change
    create_table :ip_bans do |t|
      t.integer 'staff_id'
      t.string 'reason'
      t.string 'ip'
      t.boolean 'enabled'
      t.datetime 'created_at'
      t.string 'excluded_users'
    end
  end
end
