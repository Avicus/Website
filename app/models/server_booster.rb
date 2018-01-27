class ServerBooster < ActiveRecord::Base
  belongs_to :user
  belongs_to :server

  include GraphQL::QLModel

  graphql_finders(:user_id, :server_id)

  graphql_type description: 'An XP booster which applies to a server for a specified amount of time..',
               fields: {
                   user_id: 'ID of the user who owns the booster.',
                   server_id: 'Server that the booster applies to.',
                   multiplier: 'Amount XP should be multiplied by while this booster is active.',
                   starts_at: 'When this booster begins.',
                   expires_at: 'When this booster ends.'
               }, create: true, update: true
end
