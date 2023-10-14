FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

ARG BUILD_SSH=1
ARG BUILD_MOMENTUM=0
ARG BUILD_VPNUNLIMIT=0
ARG BUILD_FIREFOX=1

## setup x11 && vnc
## Install git, supervisor, VNC, & X11 packages & tools
##
## PCManFM      - ist als schlanker und schneller Dateimanager
## LXDE         - ist eine besonders schlanke, auf GTK+ 2 aufbauende Desktopumgebung
##
RUN set -ex; \
  test ! -d /app/conf.d/ && mkdir -p /app/conf.d/ ; \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    rsync procps mlocate wget curl bash fluxbox git net-tools novnc supervisor x11vnc xterm xvfb \
    grc tree iputils-ping vim task-german tzdata locales pcmanfm lxde-core nginx ; \
  groupadd -g 5000 mms && useradd  -u 5000 -g mms -s /bin/bash -m -d /home/mms mms ; \
  sed -i 's/^# alias/alias/g;s/# export LS_OPTIONS/export LS_OPTIONS/g;/dircolors/s/^# eval/eval/g' /home/mms/.bashrc ; \
  sed -i 's/^# alias/alias/g;s/# export LS_OPTIONS/export LS_OPTIONS/g;/dircolors/s/^# eval/eval/g' /root/.bashrc ; \
  echo "alias netstat='grc netstat -lntup'" >> /root/.bashrc ; \
  sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'scale');/g" /usr/share/novnc/app/ui.js ; \
  sed -i "s/UI.initSetting('reconnect', false);/UI.initSetting('reconnect', true);/g" /usr/share/novnc/app/ui.js ; \
  sed -i "s/var autoconnect = WebUtil.getConfigVar('autoconnect', false);/var autoconnect = WebUtil.getConfigVar('autoconnect', true);/g" /usr/share/novnc/app/ui.js ; \
  ln -s --force vnc.html /usr/share/novnc/index.html ; \
  ln -s --force ../sites-available/000-novnc.conf /etc/nginx/sites-enabled/

COPY entrypoint.sh /app/entrypoint.sh
COPY supervisord.conf /app/supervisord.conf
COPY conf.d/ /app/conf.d/
COPY 000-novnc.conf /etc/nginx/sites-available/000-novnc.conf

# setup timezone
RUN rm --force  --verbose /etc/localtime && \
  ln -s --force --verbose --symbolic /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
  dpkg-reconfigure --frontend=noninteractive tzdata

# setup lang
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen ; \
  sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen ; \
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen ; \
  dpkg-reconfigure --frontend=noninteractive locales

# Setup demo environment variables
ENV HOME=/root \
  DEBIAN_FRONTEND=noninteractive \
  DISPLAY=:0.0 \
  DISPLAY_WIDTH=1600 \
  DISPLAY_HEIGHT=1200 \
  RUN_XTERM=yes \
  RUN_DESKTOP=lxde \
  RUN_FLUXBOX=no \
  RUN_LXDE=yes \
  SHELL=/bin/bash \
  LANG=de_DE.UTF-8 \
  LANGUAGE=de_DE.UTF-8 \
  LC_ALL=de_DE.UTF-8 \
  TIMEZONE=Europe/Berlin \
  TZ=Europe/Berlin

# setup SSH
ENV RUN_SSH=yes
RUN set -ex ; \
  if [ ${BUILD_SSH:-0} -gt 0 2>/dev/null ] ; then \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server openssh-client ; \
    ssh-keygen -A ; \
    sed -i 's/#PidFile/PidFile/g' /etc/ssh/sshd_config ; \
    test ! -d /run/sshd && mkdir -p /run/sshd ; \
    echo 'd /var/run/sshd 0755 root root' > /usr/lib/tmpfiles.d/sshd.conf && \
    systemd-tmpfiles --create 2>/dev/null ; \
  else \
    unset RUN_SSH ; \
    rm -f /usr/lib/tmpfiles.d/sshd.conf /app/conf.d/sshd.conf ; \
    sed -i '/case.*RUN_SSH/d' /app/entrypoint.sh ; \
    DEBIAN_FRONTEND=noninteractive apt-get remove openssh-server openssh-client -y ; \
  fi

## setup momentum
## https://momentum-client.com/#download
COPY momentum.deb /app/momentum.deb
ENV RUN_MOMENTUM=no
RUN set -ex ; \
  if [ ${BUILD_MOMENTUM:-0} -gt 0 2>/dev/null ] ; then \
    cd /app/ && [ ! -f /app/momentum.deb ] && wget https://momentum-client.com/apps/momentum.deb ; \
    DEBIAN_FRONTEND=noninteractive apt-get update --allow-releaseinfo-change && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libasound2 procps libgbm1 && \
    usermod -m -d /opt/momentum/ mms ; \
    dpkg -i /app/momentum.deb ; \
    for i in Downloads nzb tmp ; do mkdir -p /opt/momentum/Momentum/$i ; done ; \
    chown -R mms:mms /opt/momentum/ ; \
    DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y ; \
    ( echo "alias netstat='grc netstat -lntup'" >> /opt/momentum/.bashrc ) ; \
    sed -i 's/^# alias/alias/g;s/# export LS_OPTIONS/export LS_OPTIONS/g;/dircolors/s/^# eval/eval/g' /opt/momentum/.bashrc ; \
    sed -i '/^Exec.*momentum-prod/s/momentum-prod.*/momentum-prod --no-sandbox/g' /usr/share/applications/momentum-prod.desktop ; \
    mkdir -p /opt/mediaserver/data/Filme \
     /opt/mediaserver/data/Fotos \
     /opt/mediaserver/data/Musik \
     /opt/mediaserver/data/Serien \
     /opt/mediaserver/data/Bücher && \
     chown -R mms:mms /opt/mediaserver/ ; \
  else \
    unset RUN_MOMENTUM ; \
    sed -i '/case.*RUN_MOMENTUM/d' /app/entrypoint.sh ; \
    rm -f /app/conf.d/momentum.conf /app/momentum.deb ; \
  fi

## setup firefox
ENV RUN_FIREFOX=no
RUN set -ex ; \
  if [ ${BUILD_FIREFOX:-0} -gt 0 2>/dev/null ] ; then \
    DEBIAN_FRONTEND=noninteractive apt-get install firefox-esr firefox-esr-*de* -y ; \
  else \
    unset RUN_FIREFOX ; \
    sed -i '/case.*RUN_VPNUNLIMIT/d' /app/entrypoint.sh ; \
    rm -f /app/conf.d/firefox.conf ; \
  fi

## setup vpn-unlimited
COPY vpn-unlimited.deb /app/vpn-unlimited.deb
ENV RUN_VPNUNLIMIT=no
RUN set -ex ; \
  if [ ${BUILD_VPNUNLIMIT:-0} -gt 0 2>/dev/null ] ; then \
    echo "build BUILD_VPNUNLIMIT $BUILD_VPNUNLIMIT" && sleep 3 ; \
    cd /app/ && \
    [ ! -f /app/vpn-unlimited.deb ] && \
    wget https://www.vpnunlimited.com/api/keepsolid/vpn-download?platform=linux-new -O ./vpn-unlimited.deb ; \
    DEBIAN_FRONTEND=noninteractive apt-get install libboost-dev resoveconf -y ; \
    dpkg -i /app/vpn-unlimited.deb ; \
  else \
    unset RUN_VPNUNLIMIT ; \
    echo "build BUILD_VPNUNLIMIT $BUILD_VPNUNLIMIT" && sleep 3 ; \
    rm -f /app/vpn-unlimited.deb /app/conf.d/vpn-unlimited.conf ; \
    sed -i '/case.*RUN_VPNUNLIMIT/d' /app/entrypoint.sh ; \
  fi

## atleast
RUN DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y && updatedb

ENV HOME=/opt/momentum
CMD ["/app/entrypoint.sh"]
VOLUME ["/opt/mediaserver/data","/opt/momentum"]
WORKDIR /opt/momentum/
EXPOSE 8080 22
