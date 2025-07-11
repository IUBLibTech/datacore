# minimum gem update:
# bundle update --source name_of_gem

source 'https://rubygems.org'

# workarounds for gems failing to build
require 'pathname'
if Pathname.new('vendor/bundle/ruby/2.7.0/gems/libxml-ruby-3.1.0').exist?
  gem 'libxml-ruby', '3.1.0', path: 'vendor/bundle/ruby/2.7.0/gems/libxml-ruby-3.1.0'
else
  gem 'libxml-ruby', '3.1.0'
end
gem "posix-spawn", github: "https://github.com/rtomayko/posix-spawn/pull/93"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'hyrax', '~>2.9'

gem 'mysql2' # still somehow in 0.x releases...

gem 'config'

# Date range support
gem 'edtf'

# ruby 2.7 support
gem 'bigdecimal', '~> 1.4.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.8'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.6'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'font-awesome-sass', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
#
gem 'resque'
gem 'resque-pool'
gem 'resque-web', '~> 0.0.7', require: 'resque_web'

gem 'resque-scheduler'
gem 'resque-scheduler-web'
gem 'active_scheduler'

gem 'net-ldap'

# temporarily hold back bulkrax version to 0.1.0
gem 'bulkrax', git: 'https://github.com/samvera-labs/bulkrax.git', ref: '5299b81' # branch: 'main'

# custom datacite client
gem 'datacite', git: 'https://github.com/IUBLibTech/datacite-ruby', branch: 'datacore'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Begin security vulnerability mitigation
# bundle update --source gem-name
gem 'bootstrap-sass', '~> 3.4.1'
gem 'loofah', '~> 2.19.1'
gem 'rack', '~> 2.2.6'
gem 'rubyzip', '~> 2.3.0'
gem 'sassc', '>= 2.0.0'
gem 'sinatra', '~> 3.0.6'
gem 'sprockets', '3.7.2' # javascript errors with newer
# End security vulnerability mitigation

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rubocop'
  gem 'rubocop-rspec'
end

gem 'clamav-client'
gem 'down', '~> 4.4'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'jira-ruby', '~> 1.1'
gem 'okcomputer', '~> 1.17'
gem 'omniauth'
gem 'omniauth-cas'
gem 'ldap_groups_lookup', '~> 0.11.0'
gem 'hydra-role-management'
gem 'riiif', '~> 1.1'
gem 'rsolr', '>= 1.0'
group :development, :test do
  gem 'capybara'
  gem 'chromedriver-helper'
  gem 'database_cleaner'
  gem 'factory_bot', require: false
  gem 'fcrepo_wrapper'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver', '~> 4.2.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov'
  gem 'coveralls_reborn'
  gem 'solr_wrapper', '~> 2.1.0'
end

gem 'willow_sword', github: 'notch8/willow_sword', ref: '0a669d7'

gem 'dotenv-rails'
gem 'recaptcha'
gem 'redlock', '~> 1.2' # redis locking fails on newer
gem 'flipflop', '2.6.0' # hyrax 2.9.6 interaction breaks on newer versions
gem 'rack-attack', '~> 6.7'
