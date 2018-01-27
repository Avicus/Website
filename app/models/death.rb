class Death < ActiveRecord::Base
  belongs_to :user

  include GraphQL::QLModel

  graphql_finders(:user_id, :cause, :user_hidden, :cause_hidden)

  graphql_type description: 'When a player dies in a match, duh.',
               fields: {
                   user_id: 'ID of the user who died.',
                   cause: 'ID of the user who caused this death.',
                   user_hidden: 'If the user has hidden this death with a stats reset.',
                   cause_hidden: 'If the cause has hidden this death (their kill, respectively) with a stats reset.'
               },
               create: true

  def cause_user
    User.find cause
  end
end