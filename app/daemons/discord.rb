#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
ENV['daemon'] = 'true'

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$run = true

trap ('TERM') { $run = false }
trap ('INT') { $run = false }

Rails.logger.auto_flushing = true if Rails.logger.respond_to?(:auto_flushing)

require 'discord/main.rb'

connect

while $run do
end

cleanup

