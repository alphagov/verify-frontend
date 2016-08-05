#!/bin/bash -eu

export HEADLESS=true
export DISPLAY=:0

pkgr package . --version="${BUILD_NUMBER}" --iteration=1 --name=front --buildpack https://github.com/heroku/heroku-buildpack-ruby --env STACK=cedar-14
