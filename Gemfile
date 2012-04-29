source 'http://rubygems.org'

gem 'rails', '3.2'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :production do
 gem 'pg' 
 gem 'thin'
 gem 'dalli'
end
group :development, :test do
  gem 'sqlite3'
  gem 'nifty-generators'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end

gem 'json_pure'
gem 'geocoder'      	# complete geocoding solution for rails
gem 'jquery-rails'  	# rails g jquery:install

gem 'devise'			# a mature flexible authentication solution
gem 'omniauth-facebook'	# facebook authentication

# add seamless CoffeeScript support to Rails applications
#gem 'therubyracer'   # javascript interpreter to run coffeescript compiler


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
