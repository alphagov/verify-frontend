#!/bin/sh -eu
bundle
export HEADLESS=true
export DISPLAY=:0
bundle exec govuk-lint-ruby app lib spec
bundle exec govuk-lint-sass app/assets/stylesheets
bundle exec rspec
bundle exec rake spec:javascripts
RAILS_ENV=production dotenv bundle exec rake assets:precompile
RAILS_ENV=production dotenv bundle exec rake tmp:clear

cp -r public/new-assets public/assets

pkgr package . --version="${BUILD_NUMBER}" --iteration=1 --name=front
