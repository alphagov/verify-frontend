#!/bin/sh -eu

mkdir -p /ida
[ ! -L /ida/front ] && ln -s /opt/front /ida/front

# set file ownerships to root except those written to by the app
chown -R root:root /opt/front
chown -R deployer:deployer /opt/front/tmp
chown -R deployer:deployer /opt/front/log

# We manage service restarts via the meta package
ln -fs /opt/front/upstart/front.conf /etc/init/front.conf

# We want to ensure upstart realizes it's config may have changed.
/sbin/initctl reload-configuration
