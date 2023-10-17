#!/bin/bash

sed -i '/^command/d' /app/supervisor/conf.d/x11vnc.conf
if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2 2>&1 | sed 's/^/+ /'
    chmod 400 /.password*
    export VNC_PASSWORD=
    echo 'command = bash -c "sleep 5 && x11vnc -forever -shared -quiet -rfbauth /.password2"' >> /app/supervisor/conf.d/x11vnc.conf
else
    echo 'command = bash -c "sleep 5 && x11vnc -forever -shared -quiet"' >> /app/supervisor/conf.d/x11vnc.conf
fi
