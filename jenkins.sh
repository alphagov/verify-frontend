#/usr/bin/env sh
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake tmp:clear
pkgr package . --version=${BUILD_NUMBER} --iteration=1 --name=front
