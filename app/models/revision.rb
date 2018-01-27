class Revision < ActiveRecord::Base
  belongs_to :user

  validates_size_of :title, :within => 5..45
  validates_presence_of :body, :message => 'cannot be blank'

  before_validation :strip_whitespace

  # Remove all unnecessary whitespace from the revision.
  def strip_whitespace
    if self.title.presence
      self.title = self.title.strip
    end
    while true
      if self.body.end_with?('<br>') == false && self.body.end_with?('&nbsp;') == false
        break
      end
      self.body = self.body.chomp('<br>').chomp('&nbsp;').strip
    end
  end

  validate :valid_tag

  # Check if the tag for this revision is valid to the context in which it is in.
  def valid_tag
    unless reply? || !tag.presence
      if category.tags.blank?
        # No tags allowed
        if tag.presence
          errors.add(:tag, 'should be empty.')
        end
      else
        tags = category.tags.split(',')

        # Tags have permissions
        unless category.can_execute?(user, :tag)
          errors.add(:tag, 'cannot be set due to lack of permissions.')
        end


        # Check category tags
        unless tags.include?(tag)
          errors.add(:tag, 'is not valid for this category.')
        end
      end
    end
  end

  # Check if the revision is a reply.
  def reply?
    title == 'reply'
  end

  # Get the category of the revision.
  def category
    Category.find_by_id(category_id)
  end

  # Get the reply that this revision is for.
  def reply
    Reply.find_by_id(reply_id)
  end

  # Get the discussion of the revision.
  def discussion
    Discussion.find_by_id(discussion_id)
  end

  # Get an application-wide link to the category that this revision is in.
  def category_url
    "/forums/categories/#{category_id}"
  end

  # Check if this revision is archived.
  def archived?
    archived == 1
  end
end