#!/usr/bin/env bash

set -e
cd "$(dirname "$0")"

./kill-service.sh

RUN_IN_BACKGROUND=true
if ! [ -d tmp ]; then mkdir tmp; fi

if [ "$1" == '--stub-api' ]
then
  echo "Starting stub-api server on port 50199"
  unset RUN_IN_BACKGROUND
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
eval bundle exec puma -e development -p 50300 ${RUN_IN_BACKGROUND:+&}
