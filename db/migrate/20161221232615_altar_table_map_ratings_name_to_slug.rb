class AltarTableMapRatingsNameToSlug < ActiveRecord::Migration[5.1]
  def self.up
    rename_column :map_ratings, :map_name, :map_slug
  end

  def self.down
    rename_column :map_ratings, :map_slug, :map_name
  end
end
