# Represents objects where permissions should be based on ownership.
#
# Implementations that have a `perms_ident` method, that will be used to generate the location in the permissions hash
# If this is not present, the class name downcased and pluralized will be used.
#
# Implementations that have the `handle_ids` method set to true will use the object's ID during permissions hash retrieval.
module Permissions::ScopedExecutable

  # NOTE: Each class needs to implement the owner?(user) and perms_ident methods in order for scopes to work
  # If the class has no owner, executable should be used instead

  # Check if a user can perform an action.
  # If user is nil, will return false.
  # Action can have multiple arguments, and will be queried into the hash as-is.
  def can_execute?(user, *action)
    action.flatten!
    return false if user.nil?
    perms_ident = self.respond_to?(:perms_ident) ? self.perms_ident : self.class.name.underscore.downcase.pluralize.to_sym
    handle_ids = self.respond_to?(:handle_ids) ? self.handle_ids : false

    if handle_ids
      value = user.has_permission?(perms_ident, self.id, action, 'all') || user.has_permission?(perms_ident, self.id, :actions, action, 'all')
      if !value && self.owns?(user)
        value = user.has_permission?(perms_ident, self.id, action, 'own') || user.has_permission?(perms_ident, self.id, :actions, action, 'own')
      end
    else
      value = user.has_permission?(perms_ident, action, 'all') || user.has_permission?(perms_ident, :actions, action, 'all')
      if !value && self.owns?(user)
        value = user.has_permission?(perms_ident, action, 'own') || user.has_permission?(perms_ident, :actions, action, 'own')
      end
    end

    value
  end
end
