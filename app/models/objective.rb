class Objective < ActiveRecord::Base
  has_one :type, class_name: 'ObjectiveType', foreign_key: 'objective_id'

  include GraphQL::QLModel

  graphql_finders(:user_id, :objective_id, :hidden)

  graphql_type description: 'The completion of an objective by a user.',
               fields: {
                   user_id: 'ID of the user who completed the objective.',
                   objective_id: 'ID of the objective which was completed.',
                   hidden: 'If this completion was hidden by a stats reset gadget.',
               },
               create: true
end
