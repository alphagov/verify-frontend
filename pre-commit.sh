#!/usr/bin/env bash

bundle exec govuk-lint-ruby app config lib spec
bundle exec govuk-lint-sass app/assets/stylesheets
bundle exec rspec --exclude-pattern "spec/features/*_spec.rb"
bundle exec rspec --pattern "spec/features/*_spec.rb"
bundle exec rake spec:javascripts
