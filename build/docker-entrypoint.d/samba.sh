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

SMB_SERVER_STRING="$(echo "$SMB_SERVER_STRING" | tr -d '/\\"')"
sed -i "s/__SMB_WORKGROUP__/$SMB_WORKGROUP/g" /app/samba/config/samba.conf
sed -i "s/__SMB_NETBIOS_NAME__/$SMB_NETBIOS_NAME/g" /app/samba/config/samba.conf
sed -i "s/__SMB_SERVER_STRING__/$SMB_SERVER_STRING/g" /app/samba/config/samba.conf
sed -i '/include.*samba.mediaserver.conf/s/.*include.*/   include = \/app\/samba\/config\/samba.mediaserver.conf/g' /app/samba/config/samba.conf
