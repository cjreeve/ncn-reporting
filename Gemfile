source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.2'
ruby "2.7.0"
gem 'puma'

# gem 'active_record_union', '~> 1.3'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails' #, '~> 4.3'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks' #, '~> 2.5'

# fix top stop turbo links breaking on link page loads
gem 'jquery-turbolinks' #, '~> 2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder' #, '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.

# , '~> 0.4.0'
gem 'sdoc',          group: :doc


gem 'foundation-rails', '~> 5.5'
gem 'sass-rails', '~> 5.0'
gem 'coffee-rails', '~> 4.1'
gem 'uglifier' #, '~> 2.7'
gem 'foundation-icons-sass-rails', '~> 3.0'


gem 'simple_form' #, '~> 3.1'
gem 'state_machine' #, '~> 1.2'
gem 'will_paginate' #, '~> 3.0'
gem 'devise' #'~> 3.5'
gem 'cancancan' #, '~> 1.10'
gem 'redcarpet' #, '~> 3.3'
gem 'geocoder' #, '~> 1.4'
gem 'gpx' #, '~> 0.8'
#generate PDFs
gem 'prawn' #, '~> 2.0'
gem 'prawn-table' #, '~> 0.2'
gem 'sanitize' #, '~> 4.0'

# Image processing
gem 'carrierwave' #, '~> 0.10'
gem 'mini_magick' #, '~> 4.4'
gem 'remotipart' #, '~> 1.2'

# gem 'rmagick'
gem 'fog' #, '~> 1.22'

# error catching service
gem 'rollbar'


# Gems used for precompilling assets
group :assets do
  gem 'sprockets' #, '~> 2.12.5'
  gem 'compass-rails' #, '~> 2.0' # you need this or you get an err
end

group :test do
  gem 'shoulda-matchers' #, '~> 3.0', require: false
  gem 'database_cleaner' #, '~> 1.5'
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'rspec-rails' #, '~> 3.6'
  gem "factory_bot_rails"
  gem 'capybara' #, '~> 2.5'
  gem 'faker' #, '~> 1.6.1'
  gem 'pry'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring',        group: :development
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rb-inotify' #, '~> 0.9.7'
end

group :production do
  gem 'pg', '>= 0.18', '< 2.0'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

