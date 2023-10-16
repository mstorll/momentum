#!/bin/bash

VAR="${RUN_NGINX:-yes}"
VAR_CONFIG="$CONFIG_DIR/nginx.conf"

case "${VAR}" in 
  false|no|n|0) set_off $VAR_CONFIG ;;
  true|yes|y|1) set_on $VAR_CONFIG ;;
esac
case "${BASIC_AUTH_ENABLED:-no}" in
  yes)
    echo "+ enable HTTP base authentication"
    htpasswd -bc /app/nginx/htpasswd ${BASIC_AUTH_USER:-novnc} ${BASIC_AUTH_PASS:-novnc} 2>&1 2>&1 | sed 's/^/+ /'
    sed -i 's|#_HTTP_PASSWORD_#||' /etc/nginx/sites-enabled/default
    ;;
  no)
    sed -i 's|[[:blank:]]\+auth_basic|   #_HTTP_PASSWORD_#auth_basic|' /etc/nginx/sites-enabled/default
    ;;
esac
