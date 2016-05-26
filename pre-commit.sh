#!/usr/bin/env bash

. scripts/deploy.sh

bundle exec govuk-lint-ruby app config lib spec
success=$?

# govuk-lint-sass is very quiet. Setting the output colour
# to red makes it more obvious when it fails.
tput setaf 1
bundle exec govuk-lint-sass app/assets/stylesheets
success=$((success || $?))
tput sgr0

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

