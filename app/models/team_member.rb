class TeamMember < ActiveRecord::Base

  include GraphQL::QLModel

  graphql_finders(:user_id, :role, :team_id, :accepted)

  graphql_type description: 'Representation of a user who is apart of a team.',
               fields: {
                   user_id: 'ID of the user who is on the team.',
                   role: 'Role of the user on the team',
                   team_id: 'ID of the team that the user is on.',
                   accepted: 'If the user accepted the invitation to join the team.',
                   accepted_at: 'Date that the user acceoted the invitation to join the team.'
               }, create: true

  def user
    User.find_by_id(user_id)
  end

  def team
    Team.find_by_id(team_id)
  end
end
