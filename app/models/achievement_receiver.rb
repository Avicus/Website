class AchievementReceiver < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement

  include GraphQL::QLModel

  graphql_finders(:user_id, :achievement_id)

  graphql_type description: 'Link between a user and a specific achievement.',
               fields: {
                   user_id: 'ID of the user that received the Achievement',
                   achievement_id: 'ID of the achievement that the user is receiving.'
               }
end
