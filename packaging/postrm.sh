#!/bin/sh -eu

APP_NAME="${DPKG_MAINTSCRIPT_PACKAGE:-"front"}"

if [ -e /etc/init/${APP_NAME}.conf ]; then
  rm -f /etc/init/${APP_NAME}.conf
fi

if [ -L /etc/nginx/conf.d/${APP_NAME}.conf ]; then
  rm -f /etc/nginx/conf.d/${APP_NAME}.conf
  nginx -s reload
fi
