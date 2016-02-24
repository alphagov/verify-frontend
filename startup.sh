#!/usr/bin/env bash
./kill-service.sh
bundle exec puma -e development -d -p 50300
