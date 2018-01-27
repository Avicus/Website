class IpBan < ActiveRecord::Base

  self.inheritance_column = nil

  serialize :excluded_users

  belongs_to :staff, class_name: 'User'

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            name: 'IP Bans',
            options: [:true, :false]
        },
        :permissions_sets => [
            {
                :actions => [:create, :update]
            }
        ]
    }
  end

  def self.can_execute?(user, action)
    user.has_permission?(:ip_bans, :actions, action, true)
  end

  def owns?(user)
    user == staff
  end
end
