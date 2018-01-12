#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE[0]}")

docker build -t frontend:latest -f run.Dockerfile . 2>&1
echo "frontend:latest"
