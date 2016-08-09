#!/usr/bin/env bash
./kill-service.sh

if [ "$1" == '--stub-api' ]
then
  echo "Starting stub-api server on port 50191"
  export API_HOST=http://localhost:50191
  rackup --daemonize --port 50191 --pid tmp/stub_api.pid stub/stub_api_conf.ru
fi

bundle exec puma -e development -d -p 50300
