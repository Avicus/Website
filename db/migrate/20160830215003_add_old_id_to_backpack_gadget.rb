class AddOldIdToBackpackGadget < ActiveRecord::Migration[5.1]
  def change
    add_column :backpack_gadgets, :old_id, :integer
  end
end
