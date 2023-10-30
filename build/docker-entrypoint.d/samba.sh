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

for xdir in Filme Fotos Musik Serien Bücher .homedrive ; do
  tdir="/opt/mediaserver/data/$xdir"
  mkdir -p "$tdir" 2>/dev/null ||:
  chmod 755 "$tdir" 2>/dev/null ||:
  touch "$tdir"/.lockdir 2>/dev/null ||:
  chown root:mms "$tdir" 2>/dev/null ||:
  chown root:root "$tdir"/.lockdir 2>/dev/null ||:
  chmod g+s "$tdir" 2>/dev/null ||:
done

if [ "${SMB_OFFER_SHARE:-no}" = "yes" ] ; then
  mkdir /opt/public_share 
  touch /opt/public_share/.lockdir
  chown root:mms /opt/public_share ; chown root:root /opt/public_share/.lockdir
  chmod g+s /opt/public_share && chmod o+t /opt/public_share
  sed -i '/include.*samba.public.conf/s/.*include.*/   include = \/app\/samba\/config\/samba.public.conf/g' /app/samba/config/samba.conf
else
  rm -rf /opt/public_share
  sed -i '/include.*samba.public.conf/s/.*include.*/\;  include = \/app\/samba\/config\/samba.public.conf/g' /app/samba/config/samba.conf
fi

# usershares
xshare="$(testparm /app/samba/config/samba.conf -s 2>&1 | egrep "^[[:blank:]]*usershare path" | cut -d'=' -f2 | xargs)"
if [ -n "$xshare" ] ; then
  [ -d "$xshare" ] || mkdir -p "$xshare"
  chown root:root "$xshare" && chmod o+t "$xshare"
fi
