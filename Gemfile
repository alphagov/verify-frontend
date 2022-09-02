source 'https://rubygems.org'
ruby '2.7.6'

gem 'rails', '~> 5.2.8.1'
gem 'rails-i18n', '~> 5.1.3'
gem 'route_translator', '~> 8.2.1'

# Server
gem 'connection_pool'
gem 'http', '~> 4.4.1'
gem 'puma'
gem 'rack-handlers'

# Assets
gem 'autoprefixer-rails'
gem 'jquery-rails'
gem 'sassc', '~> 2.4.0'
gem 'uglifier', '~> 4.2.0'

gem 'mini_racer'

# Use statsd-ruby to talk collect and send metrics to graphite
gem 'statsd-ruby', '~> 1.3.0'

# Use prometheus-client to expose metrics to prometheus
#
# prometheus/client_ruby had a massive rewrite in
# https://github.com/prometheus/client_ruby/pull/95
# This is the prerelease version of that work
gem 'prometheus-client', '~> 0.10.0.pre.alpha.1'

# Use sentry-raven for sending logs to Sentry via the raven protocol
gem 'sentry-raven'

gem 'logstash-logger'
gem 'request_store', '~> 1.3.1'

gem 'email_validator', '~> 1.6'
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
gem 'ffi', '1.12.2'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.7'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test, :development do
  # Env values for session cookie duration, etc.
  gem 'dotenv-rails'

  # Automated testing
  gem 'capybara', '~> 3.35'
  gem 'jasmine'
  gem 'jasmine-jquery-rails'
  gem 'rails-controller-testing'
  gem 'rspec', '~> 3.11'
  gem 'rspec-rails', '~> 5.0'
  gem 'selenium-webdriver', '~> 3'
  gem 'webdrivers', '~> 4.0'
  gem 'webmock', require: false

  gem 'headless'
  gem 'rack-test'
  gem 'rack_session_access'
  gem 'thin'

  gem 'rubocop-govuk', '~> 3.6.0'
  gem 'scss_lint-govuk'

  gem 'codacy-coverage', { require: false }
  gem 'pry', '~> 0.13.1'
end

platforms :mswin, :mingw, :x64_mingw do
  gem 'tzinfo-data'
  gem 'win32-process'
  gem 'windows-pr'
end
