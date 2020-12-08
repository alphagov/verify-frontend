#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ -a './tmp/stub_api.pid' ]
then
  kill "$(< ./tmp/stub_api.pid)"
  rm ./tmp/stub_api.pid 2>/dev/null
fi

if [ -a './tmp/puma.pid' ]
then
  kill "$(< ./tmp/puma.pid)"
  rm ./tmp/puma.pid
fi
