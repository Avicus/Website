# Website

## Requirements:
* Ruby `5.1` or higher
* MySQL installation
* *Windows Only* Ruby [DevKit `x.x.x`](http://rubyinstaller.org/downloads) (required by nokogiri)

## Bulding API Java Classes
* Set `api-out` in `avicus.yml` to where you want the classes to go.
* Run `rake graphql:generate` to generate the classes.
* When the classes are loaded into the IDE, there will be a lot of unneeded imports, simply run Code -> Reformat Code to fix all errors

## How to create DB and create TABLES:
* Run `rake db:setup`

## How to Test:
* Install required gems with `bundle install`
* Install nokogiri manually (https://nokogiri.org/)
* Install mysql2 manually then run `sudo apt-get install libmysqlclient-dev` and `sudo gem install mysql2 -- --without-mysql-lib=${mysql-dir}/lib`
* Run the `localhost:3000` server via `rails s`
