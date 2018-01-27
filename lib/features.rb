# Staged feature releases
class Features
  class << self

    # Get the current date in CST.
    def date
      Time.now.in_time_zone('Central Time (US & Canada)').to_datetime
    end

    # Check if a user has permission to view a feature.
    def has_perm(id, user)
      user.nil? ? false : user.has_permission?(:application_controllers, :features, id, true)
    end
  end
end
