#!/bin/bash

VAR="${RUN_VPNUNLIMIT:-no}"
VAR_CONFIG="$CONFIG_DIR/vpn-unlimited.conf"

case "${VAR}" in 
  false|no|n|0) set_off $VAR_CONFIG ;;
  true|yes|y|1) set_on $VAR_CONFIG ;;
esac
