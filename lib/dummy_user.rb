# Represents a fake user class which can be used to represent states and objects where user data is required, but no user is currently present.
class DummyUser

  def has_permission?(*perm)
    return Rank.default_rank.has_permission?(perm)
  end

  def name
    ''
  end

  def is_staff
    false
  end

  def id
    -5
  end

  def team
    nil
  end

  def path
    '/login'
  end

  def link
    "<a href=\"/login\">Login</a>"
  end

  def password
    return nil
  end

  def hasPermission(node = nil)
    false
  end

  def get_permission(*args)
    return Rank.default_rank.get_permission_inherit(args)
  end

end
