#!/bin/sh -eu

if [ -e /etc/init/front.conf ]; then
  rm -f /etc/init/front.conf
fi
