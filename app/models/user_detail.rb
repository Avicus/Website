class UserDetail < ActiveRecord::Base
  include Permissions::ScopedEditable
  include Permissions::ScopedExecutable
  include Permissions::ScopedViewable
  include CachableModel

  belongs_to :user

  include GraphQL::QLModel

  graphql_finders(:user_id, :email_status, :cover_art, :gender)

  graphql_type description: 'A set of information about a user which is diaplyed on their profile.',
               fields: {
                   user_id: 'Id of the user that these details represent.',
                   email: 'Email of the user used for gravatar',
                   email_status: 'If the user has confirmed their email.',
                   avatar: 'Gravatar ID of the user.',
                   about: 'Raw HTML of the about page text of the user.',
                   cover_art: 'Path to the cover art on the profile.',
                   interests: 'List of things the user is interested in.',
                   gender: 'Gender of the user.',
                   skype: 'Skype username of the user.',
                   twitter: 'Twitter handle of the user.',
                   instagram: 'Instagram handle of the user.',
                   facebook: 'Facebook name of the user',
                   twitch: 'Twitch username of the user.',
                   steam: 'Steam ID of the user.',
                   github: 'Github username of the user.'
               }

  # Permissions start

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            :text => 'User Profiles',
            options: [:all, :own, :false],
        },
        :permissions_sets => [
            {
                :edit => [:email, :avatar, :about, :cover_art, :interests, :gender, :skype, :twitter, :facebook, :twitch, :steam, :github, :instagram],
                :view => [:ips, :old_names, :reports, :appeals],
                :actions => {:icon_packs => [:basic, :hands, :medical, :money, :battery, :transport, :christmas],
                             :color_packs => [:basic, :blue, :red, :green, :orange, :gray, :pink_purple, :brown_tan, :yellow]
                }
            }
        ]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:edit]
  end

  # Permissions end

  def user
    User.find_by_id(id)
  end

  def owns?(user)
    user == self.user
  end

  validates :steam, :skype, :facebook, :twitch, :twitter, :github, :instagram,
            :allow_blank => true, :format => {:with => /\A[0-9a-zA-Z-_.]*\Z/, :message => 'contains invalid characters.'}

  validates :steam,
            :length => {:maximum => 32}

  validates :skype,
            :length => {:maximum => 32}

  validates :facebook,
            :length => {:maximum => 50}

  validates :twitch,
            :length => {:maximum => 26}

  validates :twitter,
            :length => {:maximum => 16}

  validates :github,
            :length => {:maximum => 40}

  validates :instagram,
            :length => {:maximum => 32}

  validates :interests,
            :length => {:maximum => 100}

  validates :gender,
            :allow_blank => true, :inclusion => {:in => %w(Male Female Other), :message => 'must be a valid gender'}

  validate :cover_art_check

  def usable_icons
    icons = {}
    Packs::ICON_PACKS.each do |p|
      icons = icons.deep_merge(p.items) if p.can_use?(user)
    end
    icons
  end

  def usable_colors
    colors = []
    Packs::COLOR_PACKS.each do |p|
      colors.push(*p.items) if p.can_use?(user)
    end
    colors
  end

  def cover_art_check
    if cover_art != nil && !cover_art.include?('/assets/profiles/') && !cover_art.include?('/uploads/')
      errors.add(:cover_art, 'is invalid')
    else

    end
  end
end
