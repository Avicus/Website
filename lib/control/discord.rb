#!/usr/bin/env ruby

# Controller class to start the discord bot daemon.

require 'fileutils'
require 'daemons'

pid = Dir.pwd + '/tmp/pids'
unless File.directory?(pid)
  FileUtils.mkdir_p(pid)
end

log = Dir.pwd + '/tmp/pids'
unless File.directory?(log)
  FileUtils.mkdir_p(log)
end

Daemons.run('app/daemons/discord.rb', dir_mode: :normal, dir: pid, log_output: true, log_dir: log)