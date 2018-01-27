class ExperienceTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :prestige_season, foreign_key: 'season_id'

  include GraphQL::QLModel

  graphql_finders(:user_id, :season_id)

  graphql_type description: 'An XP reward a user receives for completing various tasks in game.',
               fields: {
                   user_id: 'ID of the user that the XP in this transaction is rewarded to.',
                   season_id: 'ID of the season which this transaction happened inside of',
                   genre: 'Game genre of this transaction.',
                   amount: 'Number of XP this transaction should represent.',
                   weight: 'The base XP value was multiplied by. The amount represented by this object already reflects this operation.',
               },
               create: true
end
