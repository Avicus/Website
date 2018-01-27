namespace :graphql do

  # Task to generate java API code from the graphql API.
  # avicus.yml contains the location that the generated files should be placed.
  # This location should generally be in the api directory of magma-core.
  # After this task is ran, an Intellij code format should be ran and the files otherwise untouched.
  # If you want to modify the contents of some files, see our fork of the graphql generation gem.

  desc 'Generate code.'
  task :generate => :environment do |t, args|
    require 'graphql_java_gen'
    require 'graphql_schema'
    require 'json'

    introspection_result = AvicusSchema.execute(GraphQL::Introspection::INTROSPECTION_QUERY)
    # require 'pp'
    # pp introspection_result
    schema = GraphQLSchema.new(introspection_result)

    GraphQLJavaGen.new(schema,
                       package_name: 'net.avicus.magma.api.graph',
                       nest_under: 'Avicus',
                       custom_scalars: [
                           GraphQLJavaGen::Scalar.new(
                               type_name: 'DateTime',
                               java_type: 'DateTime',
                               deserialize_expr: ->(expr) { "DateTime.parse(jsonAsString(#{expr}, key))" },
                               imports: ['org.joda.time.DateTime'],
                           )
                       ],
                       mutation_returns: {
                           UserLogin: %w(DisallowScope ChatData),
                           GadgetPurchase: %w(FailReason),
                           FriendAdd: %w(AddResponseData),
                           FriendRemove: %w(RemoveResponseData)
                       },
    ).save($avicus['api-out'])
  end
end
