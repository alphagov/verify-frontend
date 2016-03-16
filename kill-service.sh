#!/usr/bin/env bash
if [ -a 'tmp/puma.pid' ]
then
  kill "$(cat tmp/puma.pid)"
fi
