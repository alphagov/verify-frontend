#!/bin/sh -eu

APP_NAME="${DPKG_MAINTSCRIPT_PACKAGE:-"front"}"

if [ -d /etc/${APP_NAME}/conf.d ]; then
  rm -f /etc/${APP_NAME}/conf.d/*
fi
