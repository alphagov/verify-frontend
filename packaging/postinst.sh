front scale front=1
mkdir -p /ida
[ ! -L /ida/front ] && ln -s /opt/front /ida/front
front run rake tmp:create
