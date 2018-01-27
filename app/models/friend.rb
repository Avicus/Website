class Friend < ActiveRecord::Base
  belongs_to :user
  has_one :friend, class_name: 'User', foreign_key: 'friend_id'

  include GraphQL::QLModel

  graphql_finders(:user_id, :friend_id, :accepted)

  graphql_type description: 'Representation of a friendship between 2 users.',
               fields: {
                   user_id: 'ID of the user who initiated the friendship.',
                   friend_id: 'ID of the user who was requested.',
                   accepted: 'If the request has been accepted.',
               },
               create: true
end
