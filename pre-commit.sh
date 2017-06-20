#!/usr/bin/env bash

. scripts/deploy.sh

export RAILS_ENV=test

bundle check || bundle install
bundle exec govuk-lint-ruby app config lib spec
success=$?

# govuk-lint-sass is very quiet. Setting the output colour
# to red makes it more obvious when it fails, but we won't
# try to when there isn't a $TERM (jenkins).
if [ -t 1 ]; then
  tput setaf 1
fi

# HACK: can't get govuk-lint's exclude option to work, so hacking around it with `find`
scss_files=$(find app/assets/stylesheets -name *.scss | grep --invert-match 'vendor')

bundle exec govuk-lint-sass $scss_files
success=$((success || $?))
if [ -t 1 ]; then
  tput sgr0
fi

# Spec tests
bundle exec rake spec
success=$((success || $?))

# JavaScript tests
bundle exec rake jasmine:ci
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
