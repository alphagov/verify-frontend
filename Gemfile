source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '5.0.1'
gem 'rails-i18n', '~> 5.0'
gem 'route_translator', '~> 5.0'

# Server
gem 'puma'
gem 'rack-handlers'
gem 'http', '~> 2.0.0'
gem 'connection_pool'

# Assets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'

gem 'govuk_template'
gem 'govuk_frontend_toolkit'
gem 'govuk_elements_rails'

gem 'therubyracer', platforms: :ruby

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use statsd-ruby to talk collect and send metrics to graphite
gem 'statsd-ruby', '~> 1.3.0'

# Use sentry-raven for sending logs to Sentry via the raven protocol
gem 'sentry-raven'

gem 'logstash-logger'
gem 'request_store', '~> 1.3.1'

gem 'zendesk_api'
gem 'email_validator'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'pkgr', '~> 1.5.1'
end

group :test, :development do
  # Env values for session cookie duration, etc.
  gem 'dotenv-rails'

  # Automated testing
  gem 'rspec', '~> 3.5.0'
  gem 'rspec-rails', '~> 3.5.0'
  gem 'capybara', '~> 2.10'
  gem 'webmock', require: false
  gem 'jasmine'
  gem 'selenium-webdriver'

  gem 'rack-test'
  gem 'rack_session_access'
  gem 'headless'
  gem 'thin'

  gem 'govuk-lint'
end

platforms :mswin, :mingw, :x64_mingw do
  gem 'windows-pr'
  gem 'win32-process'
  gem 'tzinfo-data'
end
