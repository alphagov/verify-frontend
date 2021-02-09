#!/usr/bin/env bash
docker build . -t frontend-pre-commit
docker run -t frontend-pre-commit ./pre-commit.sh