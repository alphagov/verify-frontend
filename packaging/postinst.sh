#!/bin/sh -eu

APP_NAME="front"

mkdir -p /ida
[ ! -L /ida/${APP_NAME} ] && ln -s /opt/${APP_NAME} /ida/${APP_NAME}

# We manage service restarts via the meta package
ln -fs /opt/${APP_NAME}/upstart/${APP_NAME}.conf /etc/init/${APP_NAME}.conf

# We want to ensure upstart realizes it's config may have changed.
/sbin/initctl reload-configuration

chown -R deployer:deployer /opt/${APP_NAME}/log
chown -R deployer:deployer /var/log/${APP_NAME}
chown -R deployer:deployer /opt/${APP_NAME}/tmp
chgrp deployer /etc/${APP_NAME}

# deployer needs to access to all those files under bundle which are owned by root
find /opt/${APP_NAME}/vendor/bundle \( -type d -exec chmod go+rx {} \; \) , \( -type f -exec chmod go+r {} \;  \)

# symlink additional nginx config 
NGINX_CONF="/opt/${APP_NAME}/nginx/${APP_NAME}.conf"
test -f "$NGINX_CONF" && ln -sf "$NGINX_CONF" /etc/nginx/conf.d/
