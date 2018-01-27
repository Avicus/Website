class PresentFinder < ActiveRecord::Base
  belongs_to :user
  belongs_to :present

  include GraphQL::QLModel

  graphql_finders(:user_id, :present_id)

  graphql_type description: 'Link between a user and a specific present.',
               fields: {
                   user_id: 'ID of the user that found the present.',
                   present_id: 'ID of the present that the user found.'
               }
end
