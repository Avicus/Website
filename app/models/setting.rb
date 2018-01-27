class Setting < ActiveRecord::Base
  belongs_to :user

  include GraphQL::QLModel

  graphql_finders(:user_id, :key)

  graphql_type description: 'A setting which a user has configured in game.',
               fields: {
                   user_id: 'ID of the user that this setting is for.',
                   key: 'Key of the setting.',
                   value: 'Value of the setting.'
               }
end
