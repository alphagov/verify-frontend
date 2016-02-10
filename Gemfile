source 'https://rubygems.org'
ruby '2.3.0'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'
gem 'rails-i18n', '~> 4.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'dotenv-rails', :groups => [:development, :test]

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'govuk_template'
gem 'govuk_frontend_toolkit'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'puma'
gem "rack-handlers"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'http', '~> 1.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test, :development do
  gem 'rspec-rails', '~> 3.4.0'
  gem 'capybara', '~> 2.6'
  gem 'govuk-lint'
  gem 'webmock', require: false
end
