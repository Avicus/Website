class Pack
  attr_accessor :name, :items, :permission_root

  def initialize(name, items, *permission_root)
    @name = name
    @items = items
    @permission_root = permission_root.flatten
  end

  def is_in(item)
    @items.include?(item)
  end

  def can_use?(user)
    user.details.can_execute?(user, permission_root)
  end
end