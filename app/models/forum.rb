class Forum < ActiveRecord::Base
  include Permissions::Editable
  include Permissions::Executable

  has_many :categories

  after_destroy :clean_up

  # Delete dependant classes which should no longer exist if this is deleted.
  def clean_up
    cats = Category.where(forum_id: self.id)
    cats.each do |c|
      Discussion.where(category_id: c.id).each do |d|
        Reply.where(discussion_id: d.id).destroy_all
        Revision.where(discussion_id: d.id).destroy_all
        d.destroy
      end
      c.destroy
    end
  end

  # Permissions start

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            :text => 'Admin - Forums',
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :edit => [:name, :priority],
                                  :actions => [:create, :update, :destroy]
                              }]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:edit]
  end

  # Permissions end
end
