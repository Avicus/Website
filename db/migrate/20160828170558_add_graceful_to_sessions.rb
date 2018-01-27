class AddGracefulToSessions < ActiveRecord::Migration[5.1]
  def change
    add_column :sessions, :graceful, :boolean
  end
end
