class AddServerIdToPunishment < ActiveRecord::Migration[5.1]
  def change
    add_reference :punishments, :server, index: true
  end
end
