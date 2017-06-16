#!/bin/sh -eu

APP_NAME="front"

if [ -e /etc/init/${APP_NAME}.conf ]; then
  rm -f /etc/init/${APP_NAME}.conf
fi

if [ -e /etc/nginx/conf.d/${APP_NAME}.conf ]; then
  rm -f /etc/nginx/conf.d/${APP_NAME}.conf
fi
