class PrestigeLevel < ActiveRecord::Base
  belongs_to :user
  belongs_to :season, :class_name => 'PrestigeSeason'

  include GraphQL::QLModel

  graphql_finders(:user_id, :season_id, :level)

  graphql_type description: 'Represents a level of prestige earned by a user in a specific season.',
               fields: {
                   user_id: 'ID of the user who reached the level.',
                   season_id: 'ID of the season which this happened in.',
                   level: 'The level that was reached.',
               }

  def self.level(user)
    current = PrestigeLevel.where(season: PrestigeSeason.current_season, user_id: user.id).order(:level).last
    return 0 if current.nil?
    return 'MAX' if current.level == 100
    return current.level
  end
end
