#!/bin/bash

if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2 2>&1 | sed 's/^/+ /'
    chmod 400 /.password*
    sed -i 's/^command[[:blank:]]*=[[:blank:]]*x11vnc.*/& -rfbauth \/.password2/' /app/supervisor/conf.d/x11vnc.conf
    export VNC_PASSWORD=
fi
