#!/usr/bin/env bash
if [ -a './tmp/stub_api.pid' ]
then
  xargs kill < ./tmp/stub_api.pid
  rm ./tmp/stub_api.pid
fi

if [ -a './tmp/puma.pid' ]
then
  xargs kill < ./tmp/puma.pid
  rm ./tmp/puma.pid
fi

