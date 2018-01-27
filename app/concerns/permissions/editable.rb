# Represents objects that have no owner or where ownership does not matter.
#
# Implementations that have a `perms_ident` method, that will be used to generate the location in the permissions hash
# If this is not present, the class name downcased and pluralized will be used.
#
# Implementations that have the `handle_ids` method set to true will use the object's ID during permissions hash retrieval.
module Permissions::Editable

  # Check if a user can edit a field.
  # If user is nil, will return false.
  # Field will be stringified.
  def can_edit?(user, field)
    return false if user.nil?
    perms_ident = self.respond_to?(:perms_ident) ? self.perms_ident : self.class.name.underscore.downcase.pluralize.to_sym
    handle_ids = self.respond_to?(:handle_ids) ? self.handle_ids : false
    return user.has_permission?(perms_ident, self.id, :edit, field.to_s, true) if handle_ids
    return user.has_permission?(perms_ident, :edit, field.to_s, true) unless handle_ids
  end

  # Checks if a user has permission to edit any of the fields defined in the `perm_fields` hash.
  def can_edit_any?(user)
    (self.perm_fields.collect { |f| f.to_s }).any? { |field| can_view?(user, field) }
  end
end
