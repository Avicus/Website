class AltarColumnRanksWebPerms < ActiveRecord::Migration[5.1]
  def self.up
    change_table :ranks do |t|
      t.change :web_perms, :longtext
    end
  end

  def self.down
    change_table :ranks do |t|
      t.change :web_perms, :text
    end
  end
end
