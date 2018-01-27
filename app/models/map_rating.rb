class MapRating < ActiveRecord::Base
  include GraphQL::QLModel

  graphql_finders(:player, :map_slug, :map_version, :rating)

  graphql_type description: 'A 1-5 rating by a user for a specific version of a map.',
               fields: {
                   player: 'ID of the user who rated this map.',
                   map_slug: 'Slug of the map which this rating is for.',
                   map_version: 'Version of the map which this rating is for.',
                   rating: 'Rating which the user gave for this map version.',
                   feedback: 'Feedback entered in the feedback book.'
               },
               create: true, update: true
end
