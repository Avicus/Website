require 'permissions/permission.rb'
require 'permissions/permission_group.rb'

=begin
Replaces placeholders in strings with attributes defined at runtime
Args:
  text - text that contains stuff to replace
  replaceables - Multiple attributes that should replace the placeholders in the string
=end
def translate_text(text, *replaceables)
  replaceables.each do |replace|
    text = text.gsub("{#{replaceables.index(replace)}}", replace.to_s)
  end
  text
end

=begin
Generates a permission.
Args:
  parent - Parent of the permission
  text - Displayed in admin panel (short and concise descriptor)
  desc - Long description of what the permision applies to
  action - Symbolized identifier used in the hash declaration
  options - Possible options for the hash
  def_option - Default option for the selection
=end
def write_permission(text, desc, action, options, def_option = :flow)
  options << :flow unless options.include?(:flow)
  p = Permission.new(action, text, desc, options, def_option)
  return p
end

=begin
Generates a permission group.
Args:
  ident - identifier for the permission
  text - Displayed in admin panel (short and concise descriptor)
  desc - Long description of what the permision applies to
  action - Symbolized identifier used in the hash declaration
  options - Possible options for the hash
  def_option - Default option for the selection
=end
def write_permission_group(ident, text, desc, options, def_option)
  options << :flow unless options.include?(:flow)
  p = PermissionGroup.new(ident, text, desc, options, def_option)
  return p
end

=begin
Adds members to the parent group based on an array of hashes that contain identifiable attributes
Args:
  parent_group - Parent of the permissions that will contain the results of the parsing of the array
  array - Array of hashes that contain attributes
=end
def handle_permissions_set(parent_group, array)
  array.each do |set|
    options = set[:options]
    options = parent_group.options if options.nil?

    # Translatable
    def_text = set[:translate_text]
    def_text = '{0}' if def_text.nil?

    def_desc = set[:translate_desc]
    def_desc = '{0}' if def_desc.nil?

    # Translatable (Fields)
    fields_def_text = set[:translate_text]
    fields_def_text = '{0} {1}' if fields_def_text.nil?

    fields_def_desc = set[:translate_desc]
    fields_def_desc = '{0} {1}' if fields_def_desc.nil?

    def_option = set[:def_option]
    def_option = parent_group.def_option if def_option.nil?

    action_group = write_permission_group(:actions, 'Actions', '', options, def_option)

    value_group = write_permission_group(:values, 'Values', '', [:USER_VALUE], def_option)

    unless set[:actions].nil?
      if set[:actions].is_a?(Array)
        set[:actions].each do |ac|
          text = translate_text(def_text, ac.to_s)
          desc = translate_text(def_desc, ac.to_s)
          g = write_permission(text, desc, ac, options, def_option)
          g.add_to_group(action_group)
        end
        action_group.add_to_group(parent_group)
      else
        set[:actions].each do |root, acs|
          # Display
          disp_text = set[:actions][:text]
          disp_text = "#{root}" if disp_text.nil?

          disp_desc = set[:actions][:desc]
          disp_desc = '' if disp_desc.nil?

          # Translatable
          def_text = set[:actions][:translate_text]
          def_text = '{0} {1}' if def_text.nil?

          def_desc = set[:actions][:translate_desc]
          def_desc = '{0} {1}' if def_desc.nil?
          root_group = write_permission_group(root, disp_text, disp_desc, options, def_option)
          acs.each do |ac|
            text = translate_text(def_text, root, ac.to_s.gsub('_', ' '))
            desc = translate_text(def_desc, root, ac.to_s.gsub('_', ' '))
            g = write_permission(text, desc, ac, options, def_option)
            g.add_to_group(root_group)
          end if acs.is_a?(Array)
          root_group.add_to_group(parent_group)
        end
      end
    end

    set[:values].each do |field|
      text = translate_text(def_text, field.to_s)
      desc = translate_text(def_desc, field.to_s)

      g = write_permission(text, desc, field, [:USER_VALUE], def_option)
      g.add_to_group(value_group)
    end unless set[:values].nil?

    value_group.add_to_group(parent_group)

    edit_group = write_permission_group(:edit, 'Edit', '', options, def_option)
    view_group = write_permission_group(:view, 'View', '', options, def_option)

    set[:fields].each do |field|
      edit_text = translate_text(fields_def_text, 'edit', field.to_s)
      edit_desc = translate_text(fields_def_desc, 'edit', field.to_s)

      view_text = translate_text(fields_def_text, 'view', field.to_s)
      view_desc = translate_text(fields_def_desc, 'view', field.to_s)

      g = write_permission(edit_text, edit_desc, field, options, def_option)
      g1 = write_permission(view_text, view_desc, field, options, def_option)
      g.add_to_group(edit_group)
      g1.add_to_group(view_group)
    end unless set[:fields].nil?

    set[:edit].each do |field|
      text = translate_text(fields_def_text, 'edit', field.to_s)
      desc = translate_text(fields_def_desc, 'edit', field.to_s)

      g = write_permission(text, desc, field, options, def_option)
      g.add_to_group(edit_group)
    end unless set[:edit].nil?

    set[:view].each do |field|
      text = translate_text(fields_def_text, 'view', field.to_s)
      desc = translate_text(fields_def_desc, 'view', field.to_s)

      g = write_permission(text, desc, field, options, def_option)
      g.add_to_group(view_group)
    end unless set[:view].nil?

    edit_group.add_to_group(parent_group)
    view_group.add_to_group(parent_group)
    parent_group
  end
end
