# set path to application
mode = ENV['APP_MODE'] or raise "Missing APP_MODE"
app_dir = '/home/deploy/avicus.net'
shared_dir = "#{app_dir}/shared"
working_directory "#{app_dir}/current"

# Set unicorn options
preload_app true
timeout 30

# Set up socket location

# Logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

case mode
  when 'main'
    listen "#{shared_dir}/tmp/sockets/main.sock", :backlog => 64
    worker_processes 8
  when 'api'
    listen "#{shared_dir}/tmp/sockets/api.sock", :backlog => 64
    worker_processes 4
  else
    raise "Weird mode: #{mode}"
end

# Set master PID location
pid "#{shared_dir}/tmp/pids/#{mode}.pid"

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = '/home/deploy/avicus.net/current/Gemfile'
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = "#{shared_dir}/tmp/pids/#{mode}.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket
end
