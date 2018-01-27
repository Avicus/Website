class ReservedSlot < ActiveRecord::Base
  belongs_to :team

  include GraphQL::QLModel

  graphql_finders(:team_id, :server, :reservee)

  graphql_type description: 'A server reserved by a team for a period of time, usually for a scrimmage.',
               fields: {
                   team_id: 'ID of the team that owns the server.',
                   server: 'Name of the server which is reserved.',
                   reservee: 'ID of the user who made the reservation.',
                   start_at: 'When the reservation starts.',
                   end_at: 'When the reservation ends.'
               }, create: true

  def ongoing?
    start_at < Time.now && end_at > Time.now
  end
end
