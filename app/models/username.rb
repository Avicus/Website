class Username < ActiveRecord::Base
  belongs_to :user

  include GraphQL::QLModel

  graphql_finders(:user_id, :username)

  graphql_type description: 'Representation of non-unique usernames which differnet users have had at some point in time.',
               fields: {
                   user_id: 'ID of the user who had this username.',
                   username: 'The username that the userhad.'
               }, create: true
end