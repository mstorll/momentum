#!/bin/bash

set_off(){ echo "+ disable autostart in: $1" ; [ ! -w "$1" ] && echo "+++ error permission $1" && return 1 ; sed -i 's/^autostart.*/autostart = false/g' "$1" ; }
set_on(){  echo "+ enable  autostart in: $1" ; [ ! -w "$1" ] && echo "+++ error permission $1" && return 1 ; sed -i 's/^autostart.*/autostart = true/g' "$1" ; }
head(){ echo "+ " ; echo "+ $@" ; echo "+ ------------------------------------------------------" ; }

case "${REUN_DESKTOP:-lxde}" in
  fluxbox) 
    head "configure desktop FLUXBOX"
    RUN_FLUXBOX=yes
    RUN_LXDE=no
    ;;
  lxde)
    RUN_FLUXBOX=no
    RUN_LXDE=yes
    head "configure desktop LXDE"
    ;;
  *)
    RUN_FLUXBOX=no
    RUN_LXDE=yes
    head "configure desktop LXDE"
    ;;
esac

head "configure supervisord services"
case "${RUN_FLUXBOX:-yes}" in false|no|n|0) set_off /app/conf.d/fluxbox.conf ;; true|yes|y|1) set_on  /app/conf.d/fluxbox.conf ;; esac
case "${RUN_LXDE:-yes}" in false|no|n|0) set_off /app/conf.d/lxpanel.conf ;; true|yes|y|1) set_on  /app/conf.d/lxpanel.conf ;; esac
case "${RUN_XTERM:-yes}" in false|no|n|0) set_off /app/conf.d/xterm.conf ;; true|yes|y|1) set_on  /app/conf.d/xterm.conf ;; esac
case "${RUN_SSH:-yes}" in false|no|n|0) set_off /app/conf.d/sshd.conf ;; true|yes|y|1) set_on  /app/conf.d/sshd.conf ;; esac
case "${RUN_MOMENTUM:-no}" in false|no|n|0) set_off /app/conf.d/momentum.conf ;; true|yes|y|1) set_on /app/conf.d/momentum.conf ;; esac 
case "${RUN_FIREFOX:-no}" in false|no|n|0) set_off /app/conf.d/firefox.conf ;; true|yes|y|1) set_on /app/conf.d/firefox.conf ;; esac
case "${RUN_VPNUNLIMIT:-no}" in false|no|n|0) set_off /app/conf.d/vpn-unlimited.conf ;; true|yes|y|1) set_on /app/conf.d/vpn-unlimited.conf ;; esac
head "exec supervisord -c /app/supervisord.conf"
exec supervisord -c /app/supervisord.conf
