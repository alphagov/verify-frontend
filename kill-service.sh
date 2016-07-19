#!/usr/bin/env bash
if [ -a 'tmp/stub-api.pid' ]
then
  kill "$(cat tmp/stub-api.pid)"
fi

if [ -a 'tmp/puma.pid' ]
then
  kill "$(cat tmp/puma.pid)"
fi
