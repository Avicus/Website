class AddLonersToTournament < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments, :allow_loners, :boolean
  end
end
