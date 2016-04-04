#!/bin/sh -eu

mkdir -p /ida
[ ! -L /ida/front ] && ln -s /opt/front /ida/front

# We manage service restarts via the meta package
ln -fs /opt/front/upstart/front.conf /etc/init/front.conf

# We want to ensure upstart realizes it's config may have changed.
/sbin/initctl reload-configuration

chown -R deployer:deployer /opt/front/log
chown -R deployer:deployer /opt/front/tmp
