class Livestream < ActiveRecord::Base

  include GraphQL::QLModel

  graphql_finders(:channel)

  graphql_type description: 'A stream which appears on the live page.',
               fields: {
                   channel: 'Twitch username of the streamer.',
               },
               create: true, update: true

  graphql_query operation: 'allLive', name: 's',
                description: 'Find all channels which are currently live.',
                multi: true,
                resolver: ->(_, args, _) {
                  # TODO: pull from redis
                }

  def self.permission_definition
    {
        :global_options => {
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :actions => [:create, :destroy]
                              }]
    }
  end

  def self.can_execute?(user, *action)
    action.flatten!
    return false if user.nil?

    return user.has_permission?(:livestreams, :actions, action, true)
  end

  def path
    "/live/#{id}"
  end
end
