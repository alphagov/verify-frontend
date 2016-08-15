#!/usr/bin/env bash
./kill-service.sh

if [ "$1" == '--stub-api' ]
then
  echo "Starting stub-api server on port 50199"
  export API_HOST=http://localhost:50199
  BUNDLE_GEMFILE=stub/api/Gemfile bundle exec rackup  --daemonize --port 50199 --pid tmp/stub_api.pid stub/api/stub_api_conf.ru
fi

bundle exec puma -e development -d -p 50300
