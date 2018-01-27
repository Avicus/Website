class AchievementPursuit < ActiveRecord::Base
  belongs_to :user

  include GraphQL::QLModel

  graphql_finders(:slug, :user_id)

  graphql_type description: 'A pursuit towards earning an achievement.',
               fields: {
                   slug: 'Slug of the achievement used in plugins to protect against name changes.',
                   user_id: 'ID of the user currently in pursuit of the achievement.'
               }
end
