#!/usr/bin/env bash

echo "Heroku instance"

if [ "$1" == '--stub-api' ]
then
  echo "Starting stub-api server on port 50199"
  export CONFIG_API_HOST=http://localhost:50199
  export POLICY_HOST=http://localhost:50199
  export SAML_PROXY_HOST=http://localhost:50199
  (
  export BUNDLE_GEMFILE=stub/api/Gemfile
  bundle check || bundle install
  bundle exec rackup  --daemonize --port 50199 --pid tmp/stub_api.pid stub/api/stub_api_conf.ru
  )
fi

RAILS_ENV=production bundle exec puma -p $PORT
