class AddSilentToPunishment < ActiveRecord::Migration[5.1]
  def change
    add_column :punishments, :silent, :boolean
  end
end
