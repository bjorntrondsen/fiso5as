source 'https://rubygems.org'
ruby File.read(".ruby-version").strip

gem 'rails', '5.1.3'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'haml-rails'
gem 'rufus-scheduler'
gem 'newrelic_rpm'
gem "roo", "~> 2.7"
gem "figaro"

group :development, :test do
  gem 'heroku'
  gem 'pry'
  gem 'ruby-prof'
  gem 'awesome_print'
  gem 'sql_queries_count'
end

group :test do
  gem 'rspec-rails', '3.6.1'
  gem 'fabrication'
  gem 'vcr'
  gem 'webmock'
  gem 'database_cleaner'
end

group :production do
  gem 'rails_12factor'
end
