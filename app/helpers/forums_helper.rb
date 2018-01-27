module ForumsHelper
  # Get a link to a certain reply inside of a discussion.
  def find_reply_path(reply)
    discussion_path(reply.discussion, :reply => reply.id)
  end

  # Get an array of forums and categories for use in a dropdown menu.
  def self.options_for_select(user)
    all = []

    Forum.all.each do |cat|
      list = cat.categories

      viewable = ForumsHelper.filter_categories(user, list)

      next if viewable.empty?

      all.push(["--- #{cat.name} ---", -1, :disabled => 'disabled'])

      viewable.each do |topic|
        all.push([topic.name, topic.id])
      end
    end

    all
  end

  # Filter an array of categories to only ones that a user can view.
  def self.filter_categories(user, *categories)
    categories.flatten.delete_if { |c| !c.can_view?(user) }
  end

  # Get an array of categories that a user can view.
  def self.viewable_categories(user)
    categories = Category.all
    viewable = []
    categories.each do |category|
      view = category.can_view?(user)
      viewable << category if view
    end
    viewable
  end
end
