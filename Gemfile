source 'https://rubygems.org'
ruby '2.4.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.5'
# Use sqlite3 as the database for Active Record

gem 'activerecord-postgis-adapter'



# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'carrierwave', '~> 1.0'
gem 'cloudinary'
gem 'devise'
gem 'devise_token_auth'
gem 'faker', '~> 1.8.7'
gem "figaro"
gem "httparty"
gem 'influxdb'
gem 'resque'
gem 'rgeo'
gem 'rgeo-geojson'

gem 'webpacker', '~> 3.3'

gem 'dalli'
gem 'memcachier'

gem 'jquery-rails'
gem 'newrelic_rpm'
gem 'simple_form', '~> 3.5'
gem 'trix', '~> 0.11'

gem 'kaminari', '~> 1.1'

gem 'aasm'
gem 'fast_jsonapi'
gem 'high_voltage', '~> 3.0.0'
gem 'platform-api'
gem 'ransack'
gem 'yajl-ruby'
gem 'bootstrap', '~> 4.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'factory_bot_rails'
  gem 'mini_magick'
  gem 'rspec-rails', '~> 3.6'
  gem 'rubocop', '~> 0.51.0', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', github: 'thoughtbot/shoulda-matchers'
end



group :development, :test do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'sqlite3'
  gem 'database_cleaner'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
group :production do
  gem 'pg', '~> 1'
  gem 'pg_search', '~> 2.1'
  gem 'rails_12factor'
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
