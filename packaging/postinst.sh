#!/bin/bash
set -e
set -u

if [ -e "/opt/front/upstart/front.conf" ];
then
     ln -fs /opt/front/upstart/front.conf /etc/init/front.conf
     mkdir -p /ida
     [ ! -L /ida/front ] && ln -s /opt/front /ida/front
     exit 0;
else
exit 1;
fi
