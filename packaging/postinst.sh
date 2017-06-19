#!/bin/sh -eu

APP_NAME="${DPKG_MAINTSCRIPT_PACKAGE:-"front"}"

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

# symlink master app config to branch packages
if test "$APP_NAME" != "front"; then
  CONFIG_SOURCE_DIR="/etc/front/conf.d"
  CONFIG_TARGET_DIR="/etc/${APP_NAME}/conf.d"
  find "${CONFIG_SOURCE_DIR}" -mindepth 1 -maxdepth 1 -type f -exec ln -sf "{}" "${CONFIG_TARGET_DIR}/" \;
fi

# symlink additional nginx config 
NGINX_CONF="/opt/${APP_NAME}/nginx/${APP_NAME}.conf"
test -f "$NGINX_CONF" && ln -sf "$NGINX_CONF" /etc/nginx/conf.d/
nginx -s reload

# start the app
start "${APP_NAME}"
