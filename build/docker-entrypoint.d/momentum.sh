#!/bin/bash

# 31/10/2023
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

for i in Downloads nzb tmp Intermediate ; do
  for z in /opt/momentum/Momentum /opt/mediaserver/data/.homedrive/momentum ; do 
    tdir="$z/$i" 
    [ -d "$tdir" ] || mkdir -p "$tdir" 
    touch "$tdir"/.lockdir 
    chown -R mms:mms "$tdir" 
    chmod 775 "$tdir" && chmod g+s "$tdir"
    chmod 400 "$tdir"/.lockdir && chown root:root "$tdir"/.lockdir
  done 
done
