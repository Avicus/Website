class ObjectiveType < ActiveRecord::Base
  include GraphQL::QLModel

  graphql_finders(:name)

  graphql_type description: 'A type of objective which can be completed.',
               fields: {
                   name: 'Name of the objective type.',
               }
end
