#!/usr/bin/env bash

cd "$(dirname "$0")"

./kill-service.sh

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

bundle check || bundle install
bundle exec puma -e development -p 50300 &
