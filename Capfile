# Load DSL and set up stages
require 'capistrano/setup'

require 'capistrano/rbenv'
require 'capistrano3/unicorn'
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/rails/console'
require 'capistrano/rails/assets'
require 'capistrano/faster_assets'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
