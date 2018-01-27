class LongerActionTexts < ActiveRecord::Migration[5.1]
  def self.up
    change_table :actions do |t|
      t.change :text, :longtext
    end
  end

  def self.down
    change_table :actions do |t|
      t.change :text, :text
    end
  end
end
