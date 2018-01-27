namespace :local do

  # Task to create a new user.
  # TODO: This is broken right now due to the UUID site being down.

  desc 'Create a user.'
  task :create_user, [:username, :password] => :environment do |t, args|
    uuid_req = Net::HTTP.get(URI.parse("https://mcapi.ca/uuid/player/#{args[:username]}"))
    uuid = JSON.parse(uuid_req)[0]['uuid_formatted']

    unless User.where(uuid: uuid).first.nil?
      abort 'User already exists in database!'
    end

    user = User.create(
        username: args[:username],
        uuid: uuid.gsub('-', ''),
        locale: 'en_US',
        password: Digest::MD5.hexdigest($avicus['salt'] + args[:password]),
        mc_version: '47'
    )

    Username.create(user: user, username: user.name)
  end

  desc 'Generate a hash of column names that can be easily copy-pasted into the permissions hash.'
  task :columns, [:cl] => :environment do |t, args|
    clazz = args[:cl].classify.safe_constantize

    if clazz.nil?
      abort 'Class could not be found!'
    end

    res = '['
    clazz.column_names.each do |col|
      filtered = clazz.column_names.each.select do |elem|
        !(elem == 'created_at' || elem == 'updated_at' || elem == 'id')
      end
      next unless filtered.include?(col)
      res += ":#{col}"
      res += ', ' unless (col == filtered.last)
    end
    res += ']'

    puts res
  end
end