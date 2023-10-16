#!/bin/bash

VAR="${RUN_SAMBA:-no}"
VAR_CONFIG="$CONFIG_DIR/samba.conf"

case "${VAR}" in 
  false|no|n|0) set_off $VAR_CONFIG ;;
  true|yes|y|1) set_on $VAR_CONFIG ;;
esac
if [ -n "$RUN_MOMENTUM" ] ; then
  sed -i '/include.*samba.momentum/s/.*include.*/   include = \/app\/samba\/config\/samba.momentum.conf/g' /app/samba/config/samba.conf
fi
sed -i '/include.*samba.mediaserver.conf/s/.*include.*/   include = \/app\/samba\/config\/samba.mediaserver.conf/g' /app/samba/config/samba.conf
