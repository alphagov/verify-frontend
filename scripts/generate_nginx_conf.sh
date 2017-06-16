#!/bin/bash -eu

FRONT_VARIANT=${1}
CONTROL_WEIGHT=${2:-5}
VARIANT_WEIGHT=${3:-5}

cat <<EOF
# AB Test Config
upstream front-${FRONT_VARIANT} {
    server unix:/opt/front-${FRONT_VARIANT}/tmp/puma.sock fail_timeout=0;
}

upstream front-assign {
    server unix:/opt/front/tmp/puma.sock fail_timeout=0 weight=${CONTROL_WEIGHT};
    server unix:/opt/front-${FRONT_VARIANT}/tmp/puma.sock fail_timeout=0 weight=${VARIANT_WEIGHT};
}

map \$cookie_nginx_ab \$use_upstream {
    default '-assign';
    '~front/' '';
    '~front-${FRONT_VARIANT}/' '-${FRONT_VARIANT}';
}
EOF
