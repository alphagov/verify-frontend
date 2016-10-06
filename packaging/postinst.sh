#!/bin/sh -eu

mkdir -p /ida
[ ! -L /ida/front ] && ln -s /opt/front /ida/front

# We manage service restarts via the meta package
ln -fs /opt/front/upstart/front.conf /etc/init/front.conf

# We want to ensure upstart realizes it's config may have changed.
/sbin/initctl reload-configuration

chown -R deployer:deployer /opt/front/log
chown -R deployer:deployer /var/log/front
chown -R deployer:deployer /opt/front/tmp
chgrp deployer /etc/front

# deployer needs to access to all those files under bundle which are owned by root
find /opt/front/vendor/bundle \( -type d -exec chmod go+rx {} \; \) , \( -type f -exec chmod go+r {} \;  \)
