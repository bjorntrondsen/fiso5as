source 'https://rubygems.org'
ruby File.read(".ruby-version").strip


gem 'rails', '4.0.0'
gem 'pg'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'haml-rails'
gem 'nokogiri', '1.6.0' # Performance drop in 1.6.6 
gem 'rufus-scheduler'
gem 'newrelic_rpm'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'heroku'
  gem 'pry'
  gem 'ruby-prof'
end

group :test do
  gem 'rspec-rails'
  gem 'machinist'
  gem 'vcr'
  gem 'webmock'
  gem 'database_cleaner'
end

group :production do
  gem 'rails_12factor'
end
