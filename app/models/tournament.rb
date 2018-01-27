class Tournament < ActiveRecord::Base
  include Permissions::Editable
  include Permissions::Executable

  has_many :registrations, :dependent => :destroy

  validates :name,
            :length => {:minimum => 4, :maximum => 32}

  validates :about,
            :length => {:minimum => 20}

  include GraphQL::QLModel

  graphql_finders(:name, :slug)

  graphql_type description: 'An event which teams can register for and play in.',
               fields: {
                   name: 'The name of the tournament',
                   slug: 'The slug of the tournament used in the URL.',
                   about: 'Raw HTML of the about section of the tournament.',
                   open_at: 'Time when registration opens.',
                   close_at: 'Time when registration closes.',
                   header: 'If the tournament header should be shown in the UI.',
                   min: 'Minimum number of players allowed to play for each team.',
                   max: 'Maximum number of players allowed to play for each team.',
                   allow_loners: 'If this tournament allows individual users to register.'
               }, create: true

  # Permissions start

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            options: [:true, :false],
        },
        :permissions_sets => [
            {
                :actions => [:create, :update, :destroy, :bypass_times, :toggle_registrations, :view_registrations],
                :edit => [:name, :about, :open_at, :close_at, :header, :min, :max, :allow_loners]
            }
        ]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:edit]
  end

  def can_execute?(user, action)
    action = action.to_s
    return user.has_permission?(:tournaments, :actions, action, true)
  end

  def global_registration
    t = Team.global_team
    reg = Registration.where('team_id = (?) AND tournament_id = (?)', t.id, self.id).first
    reg = registrations.create(user_data: '[]', status: 0, team: t) if reg.nil?
    reg
  end

  # Permissions end

  def to_param
    slug
  end
end
