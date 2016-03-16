ln -fs /opt/front/upstart/front.conf /etc/init/front.conf
mkdir -p /ida
[ ! -L /ida/front ] && ln -s /opt/front /ida/front
/sbin/initctl reload-configuration
exit 0;
