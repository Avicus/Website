class Credit < ActiveRecord::Base
  belongs_to :user

  include GraphQL::QLModel

  graphql_finders(:user_id, name: 'CreditTransaction')

  graphql_type name: 'CreditTransaction',
               description: 'A numeric reward a user receives for completing various tasks in game.',
               fields: {
                   user_id: 'ID of the user who the credit(s) in this transaction are rewarded to.',
                   amount: 'Number of credits this transaction should represent.',
                   weight: 'Amount the base credit value was multiplied by. The amount represented by this object already reflects this operation.',
               },
               create: true
end
