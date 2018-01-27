class Punishment < ActiveRecord::Base
  include Permissions::ScopedEditable
  include Permissions::ScopedViewable

  self.inheritance_column = nil

  belongs_to :user
  belongs_to :staff, class_name: 'User'

  has_one :appeal, :dependent => :destroy

  include GraphQL::QLModel

  graphql_finders(:user_id, :staff_id, :type, :server_id, :appealed, :silent)

  graphql_type description: 'A strike against a user caused by them breaking a rule (usually).',
               fields: {
                   user_id: 'User who received this punishment.',
                   staff_id: 'User who issued this punishment.',
                   type: 'Type of punishment',
                   reason: 'The reason this punishment was issued.',
                   date: 'Date that this punishment was issued.',
                   expires: 'Date when this punishment is set to expire.',
                   appealed: 'If this punishment has been appealed.',
                   server_id: 'ID of the server that this punishment was issued on.',
                   silent: 'If the punishment was displayed in the UI when it was issued.'
               }

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            options: [:all, :issued, :false],
        },
        :permissions_sets => [{
                                  # Type isn't considered here, since you need the action permission to get to these fields.
                                  :fields => [:user_id, :staff_id, :type, :reason, :date, :expires, :appealed],
                                  :actions => {
                                      :update => [:mutes, :warns, :kicks, :tempbans, :bans, :web_bans, :web_tempbans, :tournament_bans, :discord_warns, :discord_kicks, :discord_tempbans, :discord_bans],
                                      :view => [:mutes, :warns, :kicks, :tempbans, :bans, :web_bans, :web_tempbans, :tournament_bans, :discord_warns, :discord_kicks, :discord_tempbans, :discord_bans],
                                      :view_appealed => [:mutes, :warns, :kicks, :tempbans, :bans, :web_bans, :web_tempbans, :tournament_bans, :discord_warns, :discord_kicks, :discord_tempbans, :discord_bans],
                                      :delete => [:mutes, :warns, :kicks, :tempbans, :bans, :web_bans, :web_tempbans, :tournament_bans, :discord_warns, :discord_kicks, :discord_tempbans, :discord_bans]
                                  }},
                              {
                                  :options => [:true, :false],
                                  :actions => [:mass_punish, :create]
                              },
                              {
                                  :options => [:true, :false],
                                  :actions => {
                                      :issue => [:mutes, :warns, :kicks, :tempbans, :bans, :web_bans, :web_tempbans, :tournament_bans, :discord_warns, :discord_kicks, :discord_tempbans, :discord_bans],
                                      :punish_as => [:self, :others, :console]
                                  }
                              }
        ]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:fields]
  end

  # If the punishment is appealed
  def appealed?
    appealed == 1
  end

  def can_execute?(user, action)
    action = action.to_s
    return user.has_permission?(:punishments, action.to_s, self.type.pluralize, :all) || (staff == user && user.has_permission?(:punishments, action.to_s, self.type.pluralize, :issued))
  end

  # Check if a user can issue a punishment of this type.
  def self.can_issue?(user, type)
    type = type.to_s
    user.has_permission?(:punishments, :issue, type.pluralize, true)
  end

  # Check if a user can create punishments
  def self.can_create?(user)
    user.has_permission?(:punishments, :actions, :create, true)
  end

  # Check if a user has permission to mass punish users.
  def self.can_mass_punish?(user)
    user.has_permission?(:punishments, :actions, :mass_punish, true)
  end

  # Check if a user can issue a punishment of this type.
  def can_issue?(user, type = self.type.to_sym)
    Punishment.can_issue?(user, type)
  end

  def self.can_issue_as_others?(user)
    return user.has_permission?(:punishments, :punish_as, :console, true) ||
        user.has_permission?(:punishments, :punish_as, :others, true)
  end

  # Check if a user can issue a punishment as someone.
  def self.can_issue_as?(user, as)
    if as.nil?
      return user.has_permission?(:punishments, :punish_as, :console, true)
    else
      return user.has_permission?(:punishments, :punish_as, :self, true) if user == as
      return user.has_permission?(:punishments, :punish_as, :others, true) if user != as
    end
    return false
  end

  # Check if a user can issue a punishment as someone.
  def can_issue_as?(user, as)
    Punishment.can_issue_as?(user, as)
  end

  # Check if a user can perform an action.
  def self.can_execute?(user, action)
    return true if user.has_permission?(:punishments, action, true)
    [:mutes, :warns, :kicks, :tempbans, :bans, :web_bans, :web_tempbans, :tournament_bans, :discord_warns, :discord_kicks, :discord_tempbans, :discord_bans].each do |type|
      return true if user.has_permission?(:punishments, action.to_s, type, :all)
    end
    return false
  end

  def owns?(user)
    user == staff
  end
end
