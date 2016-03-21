#!/usr/bin/env bash

bundle exec govuk-lint-ruby app lib spec
bundle exec govuk-lint-sass app/assets/stylesheets
bundle exec rspec
bundle exec rake spec:javascripts
