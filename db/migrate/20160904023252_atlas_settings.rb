class AtlasSettings < ActiveRecord::Migration[5.1]
  def change
    change_column(:settings, :key, :string)
    change_column(:settings, :value, :string)
  end
end
