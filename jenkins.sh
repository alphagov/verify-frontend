#/usr/bin/env sh
RAILS_ENV=production bundle exec rake assets:precompile
pkgr package . --version=${BUILD_NUMBER} --name=front
