Types::Base::QueryType = GraphQL::ObjectType.define do
  name 'BaseQuery' # do this to fix java issues

  GraphQL::QLModel.implementations.each { |t| t.graph_queries.each { |name, q| field name.to_sym, q } }
end
