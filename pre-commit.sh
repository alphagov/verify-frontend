#!/usr/bin/env bash

. scripts/deploy.sh

export RAILS_ENV=test

bundle check || bundle install
bundle exec rake
success=$((success || $?))

# Stub API tests
BUNDLE_GEMFILE=stub/api/Gemfile bundle
BUNDLE_GEMFILE=stub/api/Gemfile bundle exec rspec --pattern stub/api/**/*_spec.rb
success=$((success || $?))

if [ -t 1 ]; then
  if [ $success -eq 0 ]
  then
    funky_pass_banner
  else
    funky_fail_banner
  fi
fi
exit $success
