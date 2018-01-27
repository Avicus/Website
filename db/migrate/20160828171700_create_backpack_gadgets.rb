class CreateBackpackGadgets < ActiveRecord::Migration[5.1]
  def change
    create_table :backpack_gadgets do |t|
      t.references :user, index: true
      t.string :gadget_type
      t.text :gadget
      t.text :context

      t.timestamps
    end
  end
end
