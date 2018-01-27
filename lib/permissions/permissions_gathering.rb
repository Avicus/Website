# Utility class that generates permissions for the app.
require 'permissions/permissions_generator.rb'
require 'permissions/permission_utils.rb'

# Parent method to initialize all permissions from various sections of the app.
def setup_perms
  perms = []
  controller_actions(perms)
  model_actions(perms)
  perms << cat_perms
  perms << api_perms
  puts 'Permissions gathering finished...'
  puts "Permissions were loaded from #{perms.size} classes."
  return perms
end

# Get all permissions from models in the app.
def model_actions(perms)
  ActiveRecord::Base.descendants.each do |m|
    next unless m.respond_to?(:permission_definition)
    next if m.permission_definition.nil? || m.permission_definition == {}
    perms << PermissionsGenerator.new(m)
  end
  return perms
end

# Generate permissions for the API from models that extend QLModel.
def api_perms
  ident = :api
  text = 'API Permissions'
  desc = 'All permissions that have to do with the API.'
  options = [:true, :false, :flow]
  def_option = :flow

  api_global = write_permission_group(ident, text, desc, options, def_option)

  ActiveRecord::Base.descendants.each do |m|
    next unless m.included_modules.include?(GraphQL::QLModel)
    root = write_permission_group(hashify(m), m.to_s, 'Actions corresponding to ' + m.to_s.pluralize, options, def_option)

    see = write_permission_group(:see, 'Viewable Fields', 'Regulate which fields of this model a user can see.', options, def_option)

    m.graph_fields.each do |f|
      g = write_permission("View #{f}", "Allow the user to see #{f}.", hashify(f), options, def_option)
      g.add_to_group(see)
    end

    see.add_to_group(root)

    find_by = write_permission_group(:query, 'Query By', 'Regulate which fields of this model a user query by.', options, def_option)

    m.graph_finders.each do |f|
      finder = write_permission("Query by #{f}", "Allow the user to query by #{f}.", hashify(f), options, def_option)
      finder.add_to_group(find_by)
    end

    find_by.add_to_group(root)

    root.add_to_group(api_global)
  end

  mutations = write_permission_group(:mutations, 'Mutations', 'Regulate which mutations a user can perform.', options, def_option)

  AvicusSchema.types.each do |f|
    f.each do |a|
      next unless a.is_a?(GraphQL::ObjectType) && a.name.include?('Payload')
      mut = a.name.gsub('Payload', '')
      write_permission("Execute #{mut}", "Allow the user to execute the #{mut} mutation.", hashify(mut), options, def_option).add_to_group(mutations)
    end
  end

  mutations.add_to_group(api_global)

  global_options = {
      text: text,
      desc: desc,
      options: options,
      def_option: def_option
  }

  PermissionsGenerator.new('API', true, global_options, api_global, [])
end

# Make a string suitable for a hash key.
def hashify(string)
  string.to_s.underscore.to_sym
end

# Generate permissions used for the forums.
def cat_perms
  ident = :categories
  text = 'Forum permissions'
  desc = 'All permissions that have to do with the forums'
  id_based = false
  options = [:true, :false, :flow]
  def_option = :flow

  forum_global = write_permission_group(ident, text, desc, options, def_option)

  text = 'See this category'
  desc = 'Gives the user the ability to view this category'
  g = write_permission(text, desc, :see, options, def_option)
  g.add_to_group(forum_global)

  text = 'Mass Moderate'
  desc = 'Gives the user the ability to perform mass moderation actions in this category'
  g = write_permission(text, desc, :mass_moderate, options, def_option)
  g.add_to_group(forum_global)

  text = 'Create discussions this category'
  desc = 'Gives the user the ability to creat discussions in this category'
  g = write_permission(text, desc, :create, options, def_option)
  g.add_to_group(forum_global)

  states = [:normal, :archived, :locked, :stickied]

  # Actions
  ident = :actions
  parent_text = '{0} discussions in this category'
  parent_desc = 'Gives the user the ability to {0} to discussions in this category'
  options = [:all, :own, :false, :flow]
  def_option = :flow

  actions = write_permission_group(ident, 'Actions', 'Actions corresponding to the root discussion object', options, def_option)

  [:sticky, :tag, :lock, :archive].each do |action|
    text = translate_text(parent_text, action.to_s.gsub('_', ' ').capitalize)
    desc = translate_text(parent_desc, action.to_s.gsub('_', ' ').capitalize)
    g = write_permission(text, desc, action, options, def_option)
    g.add_to_group(actions)
  end

  actions.add_to_group(forum_global)

  # Edit
  ident = 'Discussion States - Edit'
  edit_parent_text = 'Edit {0} discussions in this category'
  edit_parent_desc = 'Gives the user the ability to edit {0} discussions in this category'
  edit = write_permission_group(:edit, ident, 'Permissions for each discussion state in regards to editing', options, def_option)
  # View
  ident = 'Discussion States - View'
  view_parent_text = '{0} {1} discussions in this category'
  view_parent_desc = 'Gives the user the ability to {0} {1} discussions in this category'
  view = write_permission_group(:view, ident, 'Permissions for each discussion state in regards to viewing', options, def_option)

  states.each do |action|
    edit_text = translate_text(edit_parent_text, 'Edit', action)
    edit_desc = translate_text(edit_parent_desc, 'Edit', action)
    view_text = translate_text(view_parent_text, 'View', action)
    view_desc = translate_text(view_parent_desc, 'View', action)
    g = write_permission(edit_text, edit_desc, action, options, def_option)
    g1 = write_permission(view_text, view_desc, action, options, def_option)
    g.add_to_group(edit)
    g1.add_to_group(view)
  end

  edit.add_to_group(forum_global)
  view.add_to_group(forum_global)

  # Reply To
  ident = 'Discussion States - Reply'
  parent_text = 'Reply to {0} discussions in this category'
  parent_desc = 'Gives the user the ability to reply to {0} discussions in this category'
  reply_to = write_permission_group(:reply_to, ident, 'Permissions dealing with replying to different discussion states', options, def_option)

  states.each do |action|
    text = translate_text(parent_text, action)
    desc = translate_text(parent_desc, action)
    g = write_permission(text, desc, action, options, def_option)
    g.add_to_group(reply_to)
  end

  reply_to.add_to_group(forum_global)

  # Replies
  ident = 'Replies'
  parent_text = '{0} {1} replies in this category'
  parent_desc = 'Gives the user the ability to {0} {1} replies in this category'
  replies = write_permission_group(:replies, ident, 'Permissions dealing with replies', options, def_option)

  # Edit
  edit = write_permission_group(:edit, 'Replies - Edit', 'Permissions dealing with editing replies', options, def_option)

  [:normal, :archived].each do |action|
    text = translate_text(parent_text, 'Edit', action)
    desc = translate_text(parent_desc, 'Edit', action)
    g = write_permission(text, desc, action, options, def_option)
    g.add_to_group(edit)
  end

  edit.add_to_group(replies)

  actions = write_permission_group(:actions, 'Replies - Actions', 'Permissions dealing with performing actions on replies', options, def_option)

  # Archive
  text = translate_text(parent_text, 'Archive', '')
  desc = translate_text(parent_text, 'Archive', '')
  g = write_permission(text, desc, :archive, options, def_option)
  g.add_to_group(actions)

  # Sanction
  text = translate_text(parent_text, 'Sanction', '')
  desc = translate_text(parent_text, 'Sanction', '')
  g = write_permission(text, desc, :sanction, options, def_option)
  g.add_to_group(actions)

  # Override Time
  text = 'Override post cooldown time'
  desc = 'Gives the user the ability to override the post cooldown time in this category'
  g = write_permission(text, desc, :override_time, [:true, :false, :flow], def_option)
  g.add_to_group(actions)

  actions.add_to_group(replies)

  # View
  view = write_permission_group(:view, 'Replies - View', 'Permissions dealing with viewing replies', options, def_option)

  # Archived
  text = 'View archived replies'
  desc = 'Gives the user the ability to view archived topics in this category'
  g = write_permission(text, desc, :archived, options, def_option)
  g.add_to_group(view)

  # Revisions
  text = "View a post's revisions"
  desc = 'Gives the user the ability to view revisions from posts in this category'
  g = write_permission(text, desc, :revisions, options, def_option)
  g.add_to_group(view)

  view.add_to_group(replies)

  replies.add_to_group(forum_global)

  global_options = {
      text: 'Forums',
      desc: 'All permissions that have to do with the forums',
      options: options,
      def_option: def_option
  }

  PermissionsGenerator.new('Forums', true, global_options, forum_global, [])
end

# Get perms from the main application controller.
def application_controller(perms)
  return unless ApplicationController.respond_to?(:permission_definition)
  return if ApplicationController.permission_definition.nil? || ApplicationController.permission_definition == {}
  perms << PermissionsGenerator.new(ApplicationController)
end

# Get perms from all controllers that inherit from the main application controller.
def controller_actions(perms)
  application_controller(perms)
  ApplicationController.descendants.each do |c|
    next if c == Peek::ResultsController || c.parent == Blazer # Fix for gems
    next unless c.respond_to?(:permission_definition)
    next if c.permission_definition.nil? || c.permission_definition == {}
    perms << PermissionsGenerator.new(c)
  end
  return perms
end

Avicus::Application.config.web_perms = setup_perms
