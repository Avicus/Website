require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ORG
    NAME = 'Smitdalt Network'
    DOMAIN = 'example.net'
    MC_IP = 'mine.my.craft'
    EMAIL = 'support@wamp.com'
end

module Avicus
  class Application < Rails::Application
    ActiveSupport::JSON::Encoding.use_standard_json_time_format = false

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/concerns)
    config.autoload_paths +=  Dir["#{config.root}/app/daemons/**/"]

    class << self
      def app_mode
        ENV['APP_MODE'] || 'main'
      end

      def running_rake?
        # FIXME: This needs to manually be set to false for the graphql generation task.
        File.split($0).last == 'rake'
      end

      def for_users?
        app_mode == 'main' && !running_rake? && !defined?(Rails::Console) && Rails.env == 'production' && !ENV['daemon']
      end

    end

    config.eager_load_paths -= %W(#{config.root}/app/daemons)
    config.eager_load_paths -= %W(#{config.root}/lib/control)

    if for_users?
      config.eager_load_paths += %W(#{config.root}/lib/schedules)
    end

    config.assets.precompile += %w( *.js *.css )

    config.serve_static_assets = true

    config.generators do |g|
      g.template_engine :haml
    end

    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    config.active_record.time_zone_aware_attributes = false

    # FIXME: Convert controllers to fix this.
    config.action_controller.permit_all_parameters = true

    repos = Hash.new

    # Web Main
    repos['Website'] = {:owner => 'Avicus', :name => 'avicus.net', :public => false, :path => '.', :about => 'Our website, which handles our forums, teams, user profiles, statistics displays, and more. Also handles backend logic such as ranks.'}
    # PVP
    repos['Plugins'] = {:owner => 'Avicus', :name => 'AvicusNetwork', :public => false, :path => '/var/lib/jenkins/jobs/AvicusNetwork/workspace', :about => 'The collection of all of our private plugins.'}
    # Commons
    repos['Compendium'] = {:owner => 'Avicus', :name => 'Compendium', :public => true, :path => '/var/lib/jenkins/jobs/Compendium/workspace', :about => "A collection of usefull things that Avicus uses in all of it's plugins. <b>OPEN SOURCE!</b>"}
    repos['Docs'] = {:owner => 'Avicus', :name => 'docs.avicus.net', :public => true, :path => '/html/atlas.avicus.net/current', :about => 'Documentation for writing Atlas map XMLs and generaly helpful tips. <b>OPEN SOURCE!</b>'}
    # Server
    repos['Magnet'] = {:owner => 'Avicus', :name => 'Magnet', :public => true, :path => '/var/lib/jenkins/jobs/Magnet/workspace', :about => 'Our version of Bukkit, which includes special modifications written for our servers.'}

    config.repos = repos
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    unless ENV['daemon'] || running_rake?
      config.after_initialize do
        puts 'Gathering permissions from classes...'
        require 'permissions/permissions_gathering.rb'
      end
    end

    config.enable_dependency_loading = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
