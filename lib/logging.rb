# Custom logger to separate priority events from the general app logs.

# Log a message to custom.log
def log(msg)
  date = Time.now.strftime('%m-%d-%Y %H:%M:%S')
  file.puts "[#{date}] #{msg.to_s}"
  puts msg if Rails.env == "development"
end

# Get the log file.
def file
  file = File.open(Rails.root.join('log', 'custom.log'), 'a')
  file.sync = true
  file
end

# Log a message to the admin log.
def admin_log(area, actor, action, msg)
  date = Time.now.strftime('%m-%d-%Y %H:%M:%S')
  admin_file.puts "[#{date}] - [#{area.to_s.titleize}]: #{actor.is_a?(DummyUser) ? 'Dummy' : actor.username} -> #{action.to_s.titleize} - #{msg.to_s}"
end

# Get the admin log file.
def admin_file
  file = File.open(Rails.root.join('log', 'admin_actions.log'), 'a')
  file.sync = true
  file
end
