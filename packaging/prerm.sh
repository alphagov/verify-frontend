#!/bin/sh -eu

APP_NAME="${DPKG_MAINTSCRIPT_PACKAGE:-"front"}"

status "$APP_NAME" 2>/dev/null | grep -q "^$APP_NAME start" && stop "${APP_NAME}"

if [ -d /etc/${APP_NAME}/tmp ]; then
  rm -f /etc/${APP_NAME}/tmp/*
fi

if [ -d /etc/${APP_NAME}/conf.d ]; then
  rm -f /etc/${APP_NAME}/conf.d/*
fi
