class ScrimUpdates < ActiveRecord::Migration[5.1]
  def change
    drop_table :slots

    add_column :reserved_slots, :start_at, :datetime
    add_column :reserved_slots, :end_at, :datetime
    add_column :reserved_slots, :reservee, :integer, limit: 4
    remove_column :reserved_slots, :slot_id
  end
end
