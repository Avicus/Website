# Website

## Requirements:
* Ruby `5.1` or higher
* MySQL installation
* *Windows Only* Ruby [DevKit `x.x.x`](http://rubyinstaller.org/downloads) (required by nokogiri)

## Bulding API Java Classes
* Set `api-out` in `avicus.yml` to where you want the classes to go.
* Run `rake graphql:generate` to generate the classes.
* When the classes are loaded into the IDE, there will be a lot of unneeded imports, simply run Code -> Reformat Code to fix all errors

* Run the `localhost:3000` server via `rails s`


## Installation (Linux)
### Installing Ruby
 * Install RVM Ruby Version Manager `gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \ 7D2BAF1CF37B13E2069D6956105BD0E739499BDB`
  * Download the RVM installer script and install the RVM `curl -sSL https://get.rvm.io | bash -s stable --ruby`
  * Once all installation is completed, load the RVM `source /usr/local/rvm/scripts/rvm`
  * Update RVM to latest stable `rvm get stable --autolibs=enable`
  * Install Ruby `rvm install ruby-2.7.1`
  * Make the Ruby 2.7.1 as the default Ruby version on your system `rvm --default use ruby-2.7.1`
  * Update RubyGem to latest version `gem update --system`
  * Install Ruby on Rails `gem install rails`
### Installing MySQL, Redis and Packages
  * Install NodeJS `sudo apt install nodejs redis libmysqlclient-dev`
  * Install MySQL `gem install mysql2`
  * Install nokogiri `gem install nokogiri`
  * Update bundler and install required gems `bundle update --bundler`
### Configure database.yml
  * In `config/database.yml` configure the host, database, username and password for MySQL.
  * In `config/avicus.yml` configure the host, port and password for redis.
  
  * Run `rake db:setup`
  
