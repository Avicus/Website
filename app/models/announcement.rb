class Announcement < ActiveRecord::Base
  include Permissions::Editable
  include Permissions::Executable

  include GraphQL::QLModel

  graphql_finders(:motd, :lobby, :tips, :web, :popup, :motd_format, :enabled)

  graphql_type description: 'Something that is shown in the UI.',
               fields: {
                   body: 'The text of the announcement.',
                   motd: 'If the announcement should be used for MOTDs.',
                   lobby: 'If the announcement should show in lobbies. This will be ignored if tips is also enabled.',
                   tips: 'If the announcement should be shown periodically in game.',
                   web: 'If the announcement should be displayed at the top of the website.',
                   popup: 'If the announcement should be displayed as a title when a user joins a lobby,',
                   permission: 'A minecraft permission needed to view the announcement in game.',
                   motd_format: 'If the announcement should be used as an MOTD format.',
                   enabled: 'If the announcement should be shown.'
               },
               create: true, update: true

  validate :validate_permission
  validates :body, length: {minimum: 8}
  before_validation :fix_permission, :fix_newlines

  # Convert empty permission string to nil.
  def fix_permission
    if !permission.nil? && permission.size <= 1
      self.permission = nil
    end
  end

  # Enforce linux style new lines
  def fix_newlines
    unless self.body.nil?
      self.body = self.body.gsub('\n', "\n")
    end
  end

  # Make sure permission is only used when it should be.
  def validate_permission
    if self.permission.presence
      if self.motd || self.web
        @errors.add(:permission, 'is not compatible with MOTD or web announcements')
      end
    end
  end

  # Permissions start

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :edit => [:body, :motd, :lobby, :tips, :web, :popup, :permission, :motd_format, :enabled],
                                  :actions => [:create, :update, :destroy]
                              }]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:edit]
  end

  # Permissions end
end
