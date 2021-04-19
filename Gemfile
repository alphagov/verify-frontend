source 'https://rubygems.org'
ruby '2.7.3'

gem 'rails'
gem 'rails-i18n'
gem 'route_translator'

# Server
gem 'connection_pool'
gem 'http'
gem 'puma'
gem 'rack-handlers'

# Assets
gem 'autoprefixer-rails'
gem 'jquery-rails'
gem 'sassc'
gem 'uglifier'

gem 'mini_racer'

# Use statsd-ruby to talk collect and send metrics to graphite
gem 'statsd-ruby'

# Use prometheus-client to expose metrics to prometheus
#
# prometheus/client_ruby had a massive rewrite in
# https://github.com/prometheus/client_ruby/pull/95
# This is the prerelease version of that work
gem 'prometheus-client'

# Use sentry-raven for sending logs to Sentry via the raven protocol
gem 'sentry-raven'

gem 'logstash-logger'
gem 'request_store'

gem 'email_validator'
gem 'zendesk_api'

# Use multi_json because pkgr forces the json gem to < 2.0, which is an old specification of JSON (doesn't allow top level strings)
gem 'multi_json'

gem 'browser'

# Google Chrome and Chromium browsers now treat cookies as SameSite=Lax by default
# which causes issues for end users. This gem fixes the issue by making all cookies
# specify SameSite=None. See Chromium issue: https://www.chromium.org/updates/same-site
gem 'rails_same_site_cookie', { git: "https://github.com/alphagov/rails-same-site-cookie.git", ref: "704c1958bf2518ba8248fe3d21a49361e38e911a" }

# Gem ffi in Ruby 2.6.6 requires a version of the system library `/usr/lib/libffi.dylib` that's not available on MacOS Mojave.
# Revert the gem to a previous version that works with the library available on our dev machines.
gem 'ffi'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test, :development do
  # Env values for session cookie duration, etc.
  gem 'dotenv-rails'

  # Automated testing
  gem 'capybara'
  gem 'jasmine'
  gem 'jasmine-jquery-rails'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'webmock', require: false

  gem 'headless'
  gem 'rack-test'
  gem 'rack_session_access'
  gem 'thin'

  gem 'rubocop-govuk'
  gem 'scss_lint-govuk'

  gem 'codacy-coverage', { require: false }
  gem 'pry'
end

platforms :mswin, :mingw, :x64_mingw do
  gem 'tzinfo-data'
  gem 'win32-process'
  gem 'windows-pr'
end
