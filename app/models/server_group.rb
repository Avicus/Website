class ServerGroup < ActiveRecord::Base
  include Permissions::Editable
  include Permissions::Executable

  has_many :servers

  serialize :data

  after_save :fix_data

  include GraphQL::QLModel

  graphql_finders(:name, :slug)

  graphql_type description: 'A group of servers inside of a category.',
               fields: {
                   name: 'Name of the group.',
                   slug: 'The slug of group.',
                   description: 'Description of the group used in UI.',
                   data: 'General data for this group.',
                   icon: 'Icon for the server picker'
               }, create: true, update: true

  # Permissions start

  def self.permission_definition
    {
        :id_based => false,
        :global_options => {
            options: [:true, :false],
        },
        :permissions_sets => [{
                                  :edit => [:name, :slug, :description, :data, :icon],
                                  :actions => [:create, :update, :destroy, :add_member, :remove_member]
                              }]
    }
  end

  def self.perm_fields
    self.permission_definition[:permissions_sets][0][:edit]
  end

  # Permissions end

  # Symbolize all the keys in the data hash.
  def fix_data
    unless self.data.nil?
      fixed = self.data.to_hash.deep_symbolize_keys
      self.update_column(:data, fixed)
    end
  end

  def get_data(*path)
    path.flatten!

    path.each do |d|
      path[path.index(d)] = d.to_s.to_sym
    end

    begin
      value = path.inject(data) { |a, b| a[b] }
      raise('nil') if value == nil
      return value
    rescue
      log("#{self.name} doesn't contain data path #{path}")
      return nil
    end
  end

  def should_be_up?
    # Always up
    return true unless has_uptime_data?

    hour = Time.now.utc.hour

    d = get_data(:uptime_range, Time.now.utc.strftime('%A').downcase.to_sym)

    # No data for today
    return false if d.nil?

    # In range of time
    d[:start].to_i <= hour && d[:end].to_i > hour
  end

  def has_uptime_data?
    d = get_data(:uptime_range)

    return false if d.nil?

    Date::DAYNAMES.each do |day|
      day_data = d[day.downcase.to_sym]
      next if day_data.nil?
      return true unless day_data[:start].empty? && day_data[:end].empty?
    end

    false
  end
end
