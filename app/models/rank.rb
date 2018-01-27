class Rank < ActiveRecord::Base
  include Permissions::Editable
  include Permissions::Executable
  include Cachable

  belongs_to :inheritance, foreign_key: 'inheritance_id', :class_name => 'Rank', optional: true

  serialize :web_perms

  validates :name, :presence => true

  after_save :fix_perms, :fix_mc_perms, :fix_ts_perms, :clear_cache, :fix_nils
  after_create :populate_fields

  include GraphQL::QLModel

  graphql_finders(:name, :is_staff)

  graphql_type description: 'A group of users who are assigned special properties.',
               fields: {
                   name: 'The name of the rank.',
                   mc_perms: 'List of permissions given to any user in the rank across the network.',
                   is_staff: 'If the users inside of this rank should be marked as staff.',
                   html_color: 'Color of usernames of users who are in this rank on the website.',
                   badge_color: 'Background color of the badge given to users who have this rank on the website.',
                   badge_text_color: 'Color of the text in the badge given to users who have this rank on the website.',
                   mc_prefix: 'Prefix before users who have this rank in game.',
                   mc_suffix: 'Suffix after users who have this rank in game',
                   priority: 'Sort order of this rank when being used to determine the color/prefix/suffix a user should receive.',
                   inheritance_id: 'ID of the rank which this one inherits permissions from.',
                   ts_perms: 'Permissions given to users who have this rank on TeamSpeak'
               },
               create: true, update: true

  # Get all ranks that this one should inherit from.
  def inheritance_tree
    res = []
    return res if self.inheritance.nil?
    res << self.inheritance
    res << self.inheritance.inheritance_tree
    res.flatten!
  end

  # Sets permission fields to empty values as opposed to nil on object creation.
  def populate_fields
    self.update_column(:web_perms, {})
    self.update_column(:mc_perms, [].to_yaml)
    self.update_column(:ts_perms, [].to_yaml)
  end

  # Updates empty string fields to nil.
  def fix_nils
    [:mc_prefix, :mc_suffix].each do |nillable|
      self.update_column(nillable, nil) if self.send(nillable).blank?
    end
  end

  # Get all ranks with a certain web permission.
  def self.all_with_permission(*args)
    args.flatten!
    with = []
    Rank.all.each do |r|
      with << r if r.has_permission?(args)
    end
    with
  end

  # Get (or create) the default rank.
  def self.default_rank
    rank = Rank.find_by_name('@default')
    if rank.nil?
      rank = Rank.new(name: '@default')
      rank.save
    end
    rank
  end

  # Clear the cache of this object and all of the members.
  def clear_cache
    if self == Rank.default_rank
      Cachable.flush_class(User)
      Permissions::Forums.flush(Discussion)
      Permissions::Forums.flush(Category)
      Permissions::Forums.flush(Forum)
      Permissions::Forums.flush(Reply)
    end
    flush
    self.members.each do |m|
      m.flush
      Permissions::Forums.flush(Discussion, m.id)
      Permissions::Forums.flush(Category, m.id)
      Permissions::Forums.flush(Forum, m.id)
      Permissions::Forums.flush(Reply, m.id)
    end
  end

  # Check if this rank is only used for permissions.
  def perms_only?
    self.name[0] == '@'
  end

  def self.permission_definition
    {
        :id_based => true,
        :global_options => {
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :edit => [:name, :mc_perms, :ts_perms, :web_perms, :is_staff, :html_color, :badge_color, :badge_text_color, :mc_prefix, :mc_suffix, :priority, :inheritance],
                                  :actions => {:members => [:add, :remove, :update_role], :rank => [:create, :update, :destroy]}
                              }]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:edit]
  end

  def handle_ids
    true
  end

  # Symbolize all the keys in the permissions hash.
  def fix_perms
    unless self.web_perms.nil?
      fixed = self.web_perms.to_hash.deep_symbolize_keys
      self.update_column(:web_perms, fixed)
    end
  end

  # Fix newlines in mc permissions
  def fix_mc_perms
    unless self.mc_perms.nil? || self.mc_perms == []
      fixed = self.mc_perms.gsub(/(?:\n\r?|\r\n?)/, "\n") # enforce linux style new lines
      self.update_column(:mc_perms, fixed)
    end
  end

  # Fix newlines in ts permissions
  def fix_ts_perms
    unless self.ts_perms.nil? || self.ts_perms == []
      fixed = self.ts_perms.gsub(/(?:\n\r?|\r\n?)/, "\n") # enforce linux style new lines
      self.update_column(:ts_perms, fixed)
    end
  end

  has_many :permissions

  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships, :class_name => 'User'

  # Check if a badge should be displayed for users with this rank.
  def has_badge?
    return !(self.badge_color == 'none')
  end

  # Get all members which are timed.
  def timed_members
    return self.memberships.where(:is_purchased => true)
  end

  # Get the value of a permission from the permission hash with all inherited ranks included during evaluation.
  # This will not take into account rank and forum perms with the all option.
  def get_permission_inherit(*path)
    path.flatten!

    value = get_permission_raw_inherit(path)

    if value != nil && !value.empty? && value != 'flow'
      return value
    end

    self.inheritance_tree.reverse.each do |rank|
      raw = rank.get_permission_raw_inherit(path)
      if raw != nil && !raw.empty? && raw != 'flow'
        value = raw
      end
    end

    value
  end

  # Get the value of a permission from the permission hash with all inherited ranks included during evaluation.
  # This will take into account rank and forum perms with the all option and will default to those if the hash has a flow or nil value.
  def get_permission_raw_inherit(*path)
    path.flatten!
    value = get_permission_raw(path)

    if (value == nil || value == 'flow' || value.empty?) && (path & [:categories, :ranks]).any?
      path[1] = :all
      value = get_permission_raw(path)
    end

    value
  end

  # Get the value of a permission from the permission hash.
  # This will take into account rank and forum perms with the all option and will default to those if the hash has a flow or nil value.
  def get_permission_raw(*path)
    path.flatten!
    perms = web_perms

    path.each do |perm|
      path[path.index(perm)] = perm.to_s.to_sym
    end

    begin
      value = path.inject(perms) { |a, b| a[b] }
      raise('nil') if value == nil
      return value
    rescue
      log("#{self.name} doesn't contain web_perms path #{path}")
      return nil
    end
  end

  # Check if a rank has a permission.
  def has_permission?(*args)
    args.flatten!
    $avicus['override-perms'] || cached(:has_permission_uncached?, *args)
  end

  # Check if a rank has a permission regardless of value in the cache.
  def has_permission_uncached?(*args)
    args.flatten!

    path = args[0, args.size - 1]
    check = args.last

    value = get_permission_inherit(path)
    value == check.to_s || $avicus['override-perms']
  end

  # Abilities

  def can_add_members?(user)
    user.has_permission?(:ranks, self.id, :members, :add, true)
  end

  def can_remove_members?(user)
    user.has_permission?(:ranks, self.id, :members, :remove, true)
  end
end
