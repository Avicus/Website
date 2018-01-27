# Represents special permissions used for forums classes.
# Implementation should be limited to classes that are in the forums scope.
module Permissions::Forums
  extend ActiveSupport::Concern

  # Flush all cache data for a certain or all users.
  def self.flush(clazz, user = '*')
    keys = $redis.keys('cached:' + user.to_s + ':' + clazz.name + ':*')
    $redis.del(keys) unless keys.empty?
  end

  # Flush all cache data for the class.
  def flush_class
    Permissions::Forums.flush(self.class)
  end

  included do
    after_commit :flush_class
  end

  # Check if a user can execute an action based on the state of the object.
  # If user is nil, will return false.
  # Action can have multiple arguments, and will be queried into the hash as-is.
  def can_execute_state?(user, *action)
    action.flatten!
    return false if user.nil?
    category = determine_category

    args = [:categories, category.id.to_s, action]

    key = 'cached:' + user.id.to_s + ':' + self.class.name + ':' + self.id.to_s + ':can_execute_state:' + args.flatten.to_json

    cached = $redis.get(key)
    return string_to_bool(cached) unless cached.nil?

    # Can execute everything
    visible = user.has_permission?(args + [:normal, 'all'])

    # If they can't do all and they are the author.
    if !visible && self.author == user
      visible = user.has_permission?(args + [:normal, 'own'])
    end

    # Check if stickied.
    if self.sticky?
      visible = user.has_permission?(args + [:stickied, 'all'])
      visible = visible || (self.user == user && user.has_permission?(args + [:stickied, 'own']))
    end

    # Take into account if archived.
    if visible && self.archived?
      visible = user.has_permission?(args + [:archived, 'all'])
      visible = visible || (self.author == user && user.has_permission?(args + [:archived, 'own']))
    end

    # Take into account if locked.
    if visible && self.locked?
      visible = user.has_permission?(args + [:locked, 'all'])
      visible = visible || (self.author == user && user.has_permission?(args + [:locked, 'own']))
    end

    $redis.set(key, visible)

    return visible
  end

  # Check if a user is allowed to see alerts from tags on this object.
  # If user is nil, will return false.
  # This should only be used before an object is saved, thus the category argument.
  def can_see_tag_alerts?(user, category)
    return false if user.nil?

    args = [:categories, category.id.to_s, :view]

    key = 'cached:' + user.id.to_s + ':' + self.class.name + ':can_see_tag_alerts:' + category.id.to_s
    cached = $redis.get(key)
    return string_to_bool(cached) unless cached.nil?

    # Can execute everything
    visible = user.has_permission?(args + [:normal, 'all'])

    # If they can't do all and they are the author.
    if !visible && self.author == user
      visible = user.has_permission?(args + [:normal, 'own'])
    end

    if self.is_a?(Discussion)
      # Check if stickied.
      if self.sticky?
        visible = user.has_permission?(args + [:stickied, 'all'])
        visible = visible || (self.user == user && user.has_permission?(args + [:stickied, 'own']))
      end

      # Take into account if locked.
      if visible && self.locked?
        visible = user.has_permission?(args + [:locked, 'all'])
        visible = visible || (self.author == user && user.has_permission?(args + [:locked, 'own']))
      end
    end

    # Take into account if archived.
    if visible && self.archived?
      visible = user.has_permission?(args + [:archived, 'all'])
      visible = visible || (self.author == user && user.has_permission?(args + [:archived, 'own']))
    end

    $redis.set(key, visible)

    return visible
  end

  # Check if a user can view this object.
  # This is a helper method that checks execution permissions.
  def can_view?(user)
    if self.is_a?(Category)
      can_execute?(user, :see)
    elsif self.is_a?(Discussion)
      can_execute_state?(user, :view)
    end
  end

  # Check if a user can execute an action, regardless of the state of the object.
  # If user is nil, will return false.
  # The owner is not required and can simply be ignored.
  # Action can have multiple arguments, and will be queried into the hash as-is.
  def can_execute?(user, owner, *action)
    action.flatten!
    return false if user.nil?
    category = determine_category

    # Fix for owner-less calls.
    unless owner.is_a?(User) || owner.is_a?(DummyUser)
      action = [owner] + action
      owner = nil
    end

    key = 'cached:' + user.id.to_s + ':' + self.class.name + ':' + category.id.to_s + ':can_execute:' + action.flatten.to_json
    cached = $redis.get(key)
    return string_to_bool(cached) unless cached.nil?

    can = false

    if action[0] == :create
      return false if user.is_a?(DummyUser)
      can = user.has_permission?(:categories, category.id.to_s, :create, true)
    elsif action[0] == :view
      can = user.has_permission?(:categories, category.id.to_s, :see, true)
    elsif action[0] == :see
      can = user.has_permission?(:categories, category.id.to_s, :see, true)
    else
      allow = user.has_permission?(:categories, category.id.to_s, :actions, action, 'all')

      if owner != nil
        if !allow && owner == user
          allow = user.has_permission?(:categories, category.id.to_s, :actions, action, 'own')
        end
      end

      can = allow
    end

    $redis.set(key, can)
    return can
  end

  # Check if a user can reply to this object based on state.
  # If user is nil, will return false.
  def can_reply?(user)
    return false if user.nil?
    category = determine_category

    args = [:categories, category.id.to_s, :reply_to]

    key = 'cached:' + user.id.to_s + ':' + self.class.name + ':can_reply:' + args.to_json
    cached = $redis.get(key)
    return string_to_bool(cached) unless cached.nil?

    visible = user.has_permission?(args + [:normal, 'all'])

    if !visible && self.user == user
      visible = user.has_permission?(args + [:normal, 'own'])
    end

    if visible && self.archived?
      visible = user.has_permission?(args + [:archived, 'all'])
      visible = visible || (self.user == user && user.has_permission?(args + [:archived, 'own']))
    end

    if visible && self.locked?
      visible = user.has_permission?(args + [:locked, 'all'])
      visible = visible || (self.user == user && user.has_permission?(args + [:locked, 'own']))
    end

    $redis.set(key, visible)

    return visible
  end

  # Check if a user can view revisions of this object.
  # If user is nil, will return false.
  def can_view_revisions?(user)
    return false if user.nil?
    category = determine_category
    scope = user == self.user ? 'own' : 'all'
    user.has_permission?(:categories, category.id.to_s, :replies, :view, :revisions, scope) || (scope == 'own' && user.has_permission?(:categories, category.id.to_s, :replies, :view, :revisions, 'all'))
  end

  # Check if a user is allowed to override the post cooldown time for this object.
  # If user is nil, will return false.
  def can_override_time?(user)
    return false if user.nil?
    category = determine_category
    return user.has_permission?(:categories, category.id.to_s, :replies, :actions, :override_time, true)
  end

  # Helper method to get the category from any forum object.
  def determine_category
    return self if self.is_a?(Category)
    return self.category if self.is_a?(Discussion)
    return self.discussion.category if self.is_a?(Reply)
  end

  private

  # Convert a string to a boolean.
  def string_to_bool(str)
    return str.to_s == 'true'
  end
end
