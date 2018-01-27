class Achievement < ActiveRecord::Base

  belongs_to :achievement_receiver

  include Permissions::Editable
  include Permissions::Executable

  # Permissions start

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :edit => [:slug, :name, :description],
                                  :actions => [:create, :update, :destroy, :reward, :revoke]
                              }]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:edit]
  end

  # Permissions end

  include GraphQL::QLModel

  graphql_finders(:slug, :name)

  graphql_type description: 'Something that can be earned',
               fields: {
                   slug: 'Slug of the achievement used in plugins to protect against name changes.',
                   name: 'Name of the achievement used in the UI.',
                   description: 'Description of the achievement used in the UI.'
               }

end
