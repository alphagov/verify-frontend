#!/usr/bin/env bash
if [ -a 'tmp/pids/server.pid' ]
then
  kill `cat tmp/pids/server.pid`
fi
