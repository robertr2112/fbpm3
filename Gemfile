source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'
#ruby-gemset=Rails_fb3

gem 'rails','~> 5.2.3'

# Use ActiveModel has_secure_password
gem 'bcrypt', '3.1.11'
gem 'annotate'
gem 'faker', '1.8.7'
# The following are for form help
gem 'select2-rails'
gem 'simple_form'
gem 'cocoon'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

#
# Bootstrap support gems
#
gem 'bootstrap', '4.4.1'
gem 'will_paginate-bootstrap4'
gem 'font-awesome-sass'
gem 'font-awesome-rails'
# Use SCSS for stylesheets
gem 'sassc-rails', '~>2.1.2'

# Use CoffeeScript for .coffee assets and views
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~>4.2'
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '5.1.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~>2.5'

# The following Gem is used to parse the NFL page for schedules to build
# a season.
gem 'nokogiri'

# Mail support
gem 'email_validator'

# Database.  Using the same database for production/development
gem 'pg',  '~> 0.20'

group :development do
  gem 'web-console', '>=3.3.0'
end

group :development, :test do
  gem 'byebug'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'childprocess', '0.8.0'
  gem 'letter_opener_web'
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'simplecov', require: false, group: :test
  gem 'launchy'
  gem 'libnotify', '0.9.4'
  gem 'rubocop-rspec'
  gem 'database_cleaner'
end

group :doc do
  gem 'sdoc', '0.4.1', require: false
end

group :production do
  gem 'rails_12factor'
end

# To use debugger
# gem 'debugger'

gem 'execjs'
