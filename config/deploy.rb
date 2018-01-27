# config valid only for current version of Capistrano
lock '3.5.0'

require 'capistrano/git-submodule-strategy'

set :application, 'avicus'
# FIXME: Change this when you fork!
set :repo_url, 'git@github.com:Avicus/avicus.net.git'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/avicus.yml', 'config/blazer.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('public/uploads', 'log', 'unicorn', 'tmp/pids')
set :git_strategy, Capistrano::Git::SubmoduleStrategy
set :git_keep_meta, true
set :keep_releases, 3
set :deploy_via, :copy

ROLES = %w(main api)

namespace :unicorn do
  def set_mode(role)
    ENV['APP_MODE'] = role.to_s
    set :unicorn_options, "--eval \"ENV['APP_MODE'] = '#{role}'; puts 'Set mode to ' + ENV['APP_MODE']\"" # HACK because the value set above does not seem to make it into the Unicorn process
    set :unicorn_pid, "#{fetch(:deploy_to)}/shared/tmp/pids/#{role}.pid"
  end

  desc 'Start All'
  task :start_all do
    sh "cap #{fetch :stage} unicorn:start_main"
    sh "cap #{fetch :stage} unicorn:start_api"
  end

  desc 'Stop All'
  task :stop_all do
    sh "cap #{fetch :stage} unicorn:stop_main"
    sh "cap #{fetch :stage} unicorn:stop_api"
  end

  desc 'Restart All'
  task :restart_all do
    sh "cap #{fetch :stage} unicorn:restart_main"
    sh "cap #{fetch :stage} unicorn:restart_api"
  end

  desc 'Start Main'
  task :start_main do
    set_mode('main')
    invoke 'unicorn:start'
  end

  desc 'Start API'
  task :start_api do
    set_mode('api')
    invoke 'unicorn:start'
  end

  desc 'ReStart Main'
  task :restart_main do
    set_mode('main')
    invoke 'unicorn:restart'
  end

  desc 'ReStart API'
  task :restart_api do
    set_mode('api')
    invoke 'unicorn:restart'
  end

  desc 'Stop Main'
  task :stop_main do
    set_mode('main')
    invoke 'unicorn:stop'
  end

  desc 'Stop API'
  task :stop_api do
    set_mode('api')
    invoke 'unicorn:stop'
  end
end

namespace :deploy do

  desc 'Restart running daemons.'
  task :daemons do
    on roles(:web) do
      %w(discord).each do |d|
        execute "cd '#{release_path}'; bundle exec ruby lib/control/#{d}.rb restart"
      end
    end
  end

  after :finished, 'unicorn:restart_all'
end
