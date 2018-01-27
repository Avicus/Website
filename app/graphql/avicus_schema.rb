require 'graphql/ql_model'

AvicusSchema = GraphQL::Schema.define do
  query(Types::Base::QueryType)
  mutation(Types::Base::MutationType)
  use GraphQL::Batch
  default_max_page_size 50
end
