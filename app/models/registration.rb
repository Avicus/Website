class Registration < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :team

  include GraphQL::QLModel

  graphql_finders(:tournament_id, :team_id, :status)

  graphql_type description: "A team's registration attempt for a tournament.",
               fields: {
                   tournament_id: 'ID of the tournament which this registration is for.',
                   team_id: 'ID of the team who is attempting to register.',
                   user_data: 'Data about which users (denoted by ID) have accepted the invite.',
                   status: 'If this registration has been accepted by a tournament staff member.'
               }

  # Get a human-friendly string for the status of a registration.
  def status_text
    status == 1 ? 'Accepted' : 'TBD'
  end

  # Get the JSON value of the user data.
  def json
    JSON.parse user_data
  end

  # Get all members of this registration.
  # If accepted is true, only members that have accepted the invitation will be included.
  def members(accepted)
    list = []
    if accepted
      json.each do |key, val|
        list += [key.to_i] if val.to_i == 1
      end
    else
      json.each do |key, val|
        list += [key.to_i]
      end
    end
    if team.global?
      User.where('id IN (?)', list)
    else
      team.users.where('id IN (?)', list)
    end
  end
end
