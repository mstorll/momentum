#!/bin/bash

VAR="${RUN_MOMENTUM:-no}"
VAR_CONFIG="$CONFIG_DIR/momentum.conf"

case "${VAR}" in 
  false|no|n|0) set_off $VAR_CONFIG ;;
  true|yes|y|1) set_on $VAR_CONFIG ;;
esac

[ -f $CONFIG_DIR/samba.conf ] || exit 0
if [ -n "${RUN_MOMENTUM}" ] ; then
  sed -i '/include.*momentum.conf/s/.*include/    include/g' $CONFIG_DIR/samba.conf
else
  sed -i '/include.*momentum.conf/s/.*include/    #include/g' $CONFIG_DIR/samba.conf
fi
