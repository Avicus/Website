class Report < ActiveRecord::Base
  include Permissions::Executable

  include GraphQL::QLModel

  graphql_finders(:user_id, :creator_id, :server)

  graphql_type description: 'A report made by a user accusing another user of violating rule(s).',
               fields: {
                   user_id: 'ID of the user who is being reported.',
                   creator_id: 'ID of the user who made the report.',
                   reason: 'The reason this report was made.',
                   server: 'Name of the server which this report was made on.'
               }, create: true

  def self.perms
    {
        :actions => [:view]
    }
  end

  def user
    User.find(user_id)
  end

  def creator
    if creator_id == 0
      return nil
    end
    User.find(creator_id)
  end

end
