#!/bin/bash -eu

bundle
export HEADLESS=true
export DISPLAY=:0
./pre-commit.sh
RAILS_ENV=production dotenv bundle exec rake assets:precompile
RAILS_ENV=production dotenv bundle exec rake tmp:clear

pkgr package . --version="${BUILD_NUMBER}" --iteration=1 --name=front
