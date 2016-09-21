#!/bin/bash -eu

bundle
export HEADLESS=true
export DISPLAY=:0
./pre-commit.sh
echo ${BUILD_NUMBER} > .build-number
RAILS_ENV=production dotenv bundle exec rake assets:precompile
RAILS_ENV=production dotenv bundle exec rake tmp:clear

# We need to copy the manifest file to the root of the public/assets dir due
# to heroku-buildback hardcoding where the manifest file should be
cp public/assets/${BUILD_NUMBER}/.*.json public/assets/

bundle exec pkgr package . --version="${BUILD_NUMBER}" --iteration=1 --name=front --dependencies=front-assets-${BUILD_NUMBER}
fpm --name front-assets-${BUILD_NUMBER}\
    --version 1\
    -C public/assets\
    --prefix /opt/front-assets\
    -s dir\
    -t deb\
    ${BUILD_NUMBER}/
