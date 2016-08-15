#!/usr/bin/env bash

. scripts/deploy.sh

bundle
bundle exec govuk-lint-ruby app config lib spec
success=$?

# govuk-lint-sass is very quiet. Setting the output colour
# to red makes it more obvious when it fails, but we won't
# try to when there isn't a $TERM (jenkins).
if [ -t 1 ]; then
  tput setaf 1
fi
bundle exec govuk-lint-sass app/assets/stylesheets
success=$((success || $?))
if [ -t 1 ]; then
  tput sgr0
fi

# Unit tests
bundle exec rspec --exclude-pattern "spec/features/*_spec.rb"
success=$((success || $?))

# Feature tests
bundle exec rspec --pattern "spec/features/*_spec.rb"
success=$((success || $?))

# JavaScript tests
bundle exec rake spec:javascripts
success=$((success || $?))

# Stub API tests
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
