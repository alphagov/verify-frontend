#!/usr/bin/env bash

bundle exec govuk-lint-ruby app lib spec
bundle exec rspec
bundle exec rake spec:javascripts
