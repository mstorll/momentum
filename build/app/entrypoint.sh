#!/bin/bash

set_off(){ 
  [ ! -f "$1" ] && \
    echo -e "+ \033[33mmissing\033[0m: $1" && return 1
  [ ! -w "$1" ] && \
     echo -e "+ \033[31merror\033[0m: permission $1" && return 1
  echo -e "+ autostart \033[32mOFF\033[0m: $1"
  sed -i 's/^autostart.*/autostart = false/g' "$1"
}
set_on(){  
  [ ! -f "$1" ] && \
    echo -e "+ \033[33mmissing\033[0m: $1" && return 1
  [ ! -w "$1" ] && \
    echo -e "+ \033[31merror\033[0m: permission $1" && return 1
  echo -e "+ autostart \033[32mON\033[0m: $1"
  sed -i 's/^autostart.*/autostart = true/g' "$1"
}

export CONFIG_DIR=/app/supervisor/conf.d

[ -x /docker-entrypoint.d/00-banner.sh ] && /docker-entrypoint.d/00-banner.sh
case "${RUN_DESKTOP:-lxde}" in
  fluxbox) echo "+ configure desktop FLUXBOX" ; RUN_FLUXBOX=yes ; RUN_LXDE=no ;;
  lxde) echo "+ configure desktop LXDE" ; RUN_FLUXBOX=no ; RUN_LXDE=yes ;;
  *) echo "+ configure desktop LXDE" ; RUN_FLUXBOX=no ; RUN_LXDE=yes ;;
esac

echo "+ configure supervisord services"
if [ -d "/docker-entrypoint.d/" ] ; then
  for f in $(find /docker-entrypoint.d/ -mindepth 1 -maxdepth 1 -name "*.sh" -type f | sort -n) dummy ; do
    case "$f" in
      *'dummy'|*'00-banner.sh') continue ;;
    esac
    . "$f" || echo -e "+ \033[31mfailed\033[0m: $f"
  done
fi

echo "+ "
echo -e "\033[33m--------------------------------------------------------------------------------\033[0m"
echo -e "\033[33m START SUPERVISOR\033[0m"
echo -e "\033[33m--------------------------------------------------------------------------------\033[0m"
exec /usr/bin/tini -- supervisord -n -c /app/supervisor/supervisord.conf
