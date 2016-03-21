#!/bin/sh -eu
bundle
bundle exec govuk-lint-ruby app lib spec
bundle exec govuk-lint-sass app/assets/stylesheets
bundle exec rspec
bundle exec rake spec:javascripts
HEADLESS=true DISPLAY=:0 ./pre-commit.sh
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake tmp:clear

cp -r public/new-assets public/assets

pkgr package . --version="${BUILD_NUMBER}" --iteration=1 --name=front
