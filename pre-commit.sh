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

bundle exec rspec --exclude-pattern "spec/features/*_spec.rb"
success=$((success || $?))
bundle exec rspec --pattern "spec/features/*_spec.rb"
success=$((success || $?))
bundle exec rake spec:javascripts
success=$((success || $?))

if [ $success -eq 0 ]
then
  funky_pass_banner
else
  funky_fail_banner
fi

