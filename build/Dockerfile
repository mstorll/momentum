## DOCKERFILE +++++++++++++++++++++++++++++++++++++++++++++   28/10/2023

ARG BUILD_SSH=1
ARG BUILD_MOMENTUM=1
ARG BUILD_VPNUNLIMIT=1
ARG BUILD_FIREFOX=1
ARG BUILD_SAMBA=1

#=======================================================================
FROM debian:bullseye AS PREP
#=======================================================================
ARG BUILD_MOMENTUM
ARG BUILD_VPNUNLIMIT
ARG BUILD_SAMBA

ENV DEBIAN_FRONTEND=noninteractive
COPY /app/ /app/
COPY /docker-entrypoint.d/ /docker-entrypoint.d/
RUN set -ex; \
  DEBIAN_FRONTEND=noninteractive apt-get clean --dry-run && apt-get update && apt-get install -y wget shc gcc lolcat figlet ; \
  if [ ${BUILD_SAMBA:-0} -eq 0 ] ; then \
    rm -rf /app/samba/ ; \
    rm -f /app/supervisor/conf.d/samba* /docker-entrypoint.d/samba* ; \
  fi ; \
  printf "%-80s\n" "=" | sed s'/ /=/g' > /app/copr.txt ; \
  figlet -w 80 -c '\\ docker art //       //         mstorll         \\'  >> /app/copr.txt ; \
  printf "%-80s\n" "=" | sed s'/ /=/g' >> /app/copr.txt ; \
  echo '#!/bin/bash\ntest -f /etc/copr.txt || exit 0\ntest -x /usr/games/lolcat && echo -e "$(cat /etc/copr.txt)" | /usr/games/lolcat -S 58 --force || echo -e "$(cat /app/copr.txt)"' > /app/copr.sh ; \
  shc -r -f /app/copr.sh ; \
  if [ ${BUILD_VPNUNLIMIT:-0} -gt 0 2>/dev/null ] ; then \
    wget "https://www.vpnunlimited.com/api/keepsolid/vpn-download?platform=linux-new" -O /app/vpn-unlimited.deb ; \
  else \
    rm -f /app/supervisor/conf.d/vpn-unlimited* /docker-entrypoint.d/vpn-unlimited* ; \
  fi ; \
  if [ ${BUILD_MOMENTUM:-0} -eq 0 ] ; then \
    rm -f /app/supervisor/conf.d/momentum* /docker-entrypoint.d/momentum* ; \
  else \
    wget "https://momentum-client.com/apps/momentum.deb" -O /app/momentum.deb ; \
  fi ; \
  find /docker-entrypoint.d/ -mindepth 1 -type f -exec chmod 755 {} + ; \
  find /app/supervisor/conf.d/ -mindepth 1 -type f -exec chmod 644 {} +
  ## exclude from build ... BUILD_FIREFOX ...e.g.

#=======================================================================
FROM debian:bullseye AS STAGE
#=======================================================================
ENV DEBIAN_FRONTEND=noninteractive
ARG BUILD_SSH
ARG BUILD_MOMENTUM
ARG BUILD_VPNUNLIMIT
ARG BUILD_FIREFOX
ARG BUILD_SAMBA

COPY --from=PREP /app/ /app/
COPY --from=PREP /docker-entrypoint.d/ /docker-entrypoint.d/

## run checks
RUN set +x ; \
  if [ ${BUILD_MOMENTUM:-0} -gt 0 2>/dev/null ] ; then \
    [ -f /app/momentum.deb ] || exit 7 ; \
  fi ; \
  if [ ${BUILD_VPNUNLIMIT:-0} -gt 0 2>/dev/null ] ; then \
    [ -f /app/vpn-unlimited.deb ] || exit 7 ; \
  fi ; \
  for i in /app/supervisor/conf.d/* /docker-entrypoint.d/* ; do \
    ls -la $i ; sleep 1 ; \
  done

## setup x11 && vnc
## Install git, supervisor, VNC, & X11 packages & tools
##
## PCManFM      - ist als schlanker und schneller Dateimanager
## LXDE         - ist eine besonders schlanke, auf GTK+ 2 aufbauende Desktopumgebung
##
RUN set -ex; \
  mv /app/entrypoint.sh /docker-entrypoint.sh ; \
  mkdir -p /docker-entrypoint.d/ ; \
  mv /app/copr.sh.x /usr/local/bin/copr && mv /app/copr.txt /etc/copr.txt && rm -f /app/copr* ; \
  DEBIAN_FRONTEND=noninteractive apt-get clean --dry-run && \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    rsync procps mlocate wget curl bash git net-tools novnc supervisor x11vnc xterm xvfb apt-utils debconf-utils dialog \
    python2 logapp menu tini grc lolcat tree iputils-ping vim task-german tzdata locales pcmanfm lxde-core nginx-full apache2-utils ; \
  echo "alias cat='lolcat'" >> /etc/skel/.bash_aliases ; \
  echo "alias ll='ls -lah'" >> /etc/skel/.bash_aliases ; \
  echo "alias netstat='grc netstat -lntup4'" >> /etc/skel/.bash_aliases ; \
  echo "alias supervisorctl='/usr/bin/supervisorctl -c /app/supervisor/supervisord.conf'" >> /etc/skel/.bash_aliases ; \
  sed -i 's/#[[:blank:]]*alias/alias/g;s/#[[:blank:]]*export LS_OPTIONS/export LS_OPTIONS/g;/dircolors/s/^# eval/eval/g' /etc/skel/.bashrc ; \
  cp /etc/skel/.bash_aliases /etc/skel/.bashrc /root/ ; \
  groupadd -g 5000 mms ; \
  if [ ${BUILD_SAMBA:-0} -gt 0 2>/dev/null ] ; then \
    [ -d /var/lib/samba ] && mv /var/lib/samba /app/samba/state && ln -s /app/samba/state /var/lib/samba ; \
    for i in state cache bind-dns private usershares printers config ; do mkdir -p /app/samba/$i ||: ; done ; \
  fi ; \
  [ ${BUILD_MOMENTUM:-0} -gt 0 ] && xdir=/opt/momentum || xdir=/home/mms ; \
  useradd  -u 5000 -g mms -s /bin/bash -m -d $xdir mms ; \
  mkdir -p /root/Desktop ; \
  sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'scale');/g" /usr/share/novnc/app/ui.js ; \
  sed -i "s/UI.initSetting('reconnect', false);/UI.initSetting('reconnect', true);/g" /usr/share/novnc/app/ui.js ; \
  sed -i "s/var autoconnect = WebUtil.getConfigVar('autoconnect', false);/var autoconnect = WebUtil.getConfigVar('autoconnect', true);/g" /usr/share/novnc/app/ui.js ; \
  ln -s --force vnc.html /usr/share/novnc/index.html ; \
  rm -f /etc/nginx/sites-enabled/default && mv /app/nginx/000-novnc.conf /etc/nginx/sites-enabled/default ; \
  ln -s /usr/games/lolcat /usr/bin/ ; \
  test -d /app/nginx/cert || mkdir /app/nginx/cert ; cd /app/nginx/cert ; \
  ARGDN="/C=DE/O=VNC/OU=NoVNC/OU=Self-Signed-Certificate/CN=novnc.local" ; \
  openssl req -x509 -newkey rsa:4096 -keyout cert.key -out cert.pem -days 3650 -sha256 -nodes -subj "$ARGDN" ; \
  htpasswd -bc /app/nginx/htpasswd ${BASIC_AUTH_USER:-novnc} ${BASIC_AUTH_PASS:-novnc} ; \
  mkdir /root/Templates

# try supervisor pip2
RUN apt-get remove supervisor -y ; \
  curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py ; \
  python2 get-pip.py ; \
  rm -f get-pip.py ; \
  pip2 install supervisor ; \
  pip2 install supervisor-stdout ; \
  mkdir -p /var/log/supervisor ; \
  for i in supervisorctl supervisord supervisor_stdout ; do ln -s /usr/local/bin/$i /usr/bin/ ; done

COPY nzbget.conf /opt/momentum/.config/Momentum/nzbget.conf

# setup timezone
RUN rm --force  --verbose /etc/localtime && \
  ln -s --force --verbose --symbolic /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
  dpkg-reconfigure --frontend=noninteractive tzdata

# setup lang
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen ; \
  sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen ; \
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen ; \
  dpkg-reconfigure --frontend=noninteractive locales

# Setup environment variables
# RUN_* for supervisor autostart
ENV HOME=/root \
  DEBIAN_FRONTEND=noninteractive \
  DISPLAY=:0 \
  DISPLAY_WIDTH=1600 \
  DISPLAY_HEIGHT=1200 \
  SHELL=/bin/bash \
  LANG=de_DE.UTF-8 \
  LANGUAGE=de_DE.UTF-8 \
  LC_ALL=de_DE.UTF-8 \
  TIMEZONE=Europe/Berlin \
  TZ=Europe/Berlin \
  DEBUG=0 \
  BASIC_AUTH_ENABLED=yes \
  BASIC_AUTH_USER=novnc \
  BASIC_AUTH_PASS=novnc \
  RUN_XTERM=yes \
  RUN_DESKTOP=lxde \
  RUN_LXDE=yes \
  RUN_NGINX=yes \
  RUN_MOMENTUM=no \
  RUN_VPNUNLIMIT=no \
  RUN_FIREFOX=no \
  RUN_SSH=yes \
  SMB_WORKGROUP=WORKGROUP \
  SMB_NETBIOS_NAME=WSDEBIAN \
  SMB_SERVER_STRING="Samba %v im Docker Container" \
  SMB_OFFER_SHARE=no

# setup SSH
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
    rm -f /usr/lib/tmpfiles.d/sshd.conf /app/conf.d/sshd.conf /app/supervisor/conf.d/sshd* /docker-entrypoint.d/sshd* ; \
  fi

## directory setup
RUN set -ex ; \
  if [ ${BUILD_MOMENTUM:-0} -gt 0 2>/dev/null -o ${BUILD_SAMBA:-0} -gt 0 2>/dev/null ] ; then \
    for xdir in Filme Fotos Musik Serien Bücher .homedrive ; do \
      mkdir -p /opt/mediaserver/data/$xdir && touch /opt/mediaserver/data/$xdir/.lockdir ; \
    done ; \
    chown -R root:mms /opt/mediaserver/data ; \
    chmod -R g+s /opt/mediaserver/data/ ; \
  fi ; \
  find /opt/mediaserver/data/ -name ".lockdir" -type f -exec chmod 400 {} +

## setup momentum - https://momentum-client.com/#download
##------------------------------------------------------------------------------
RUN set -ex ; \
  if [ ${BUILD_MOMENTUM:-0} -gt 0 2>/dev/null ] ; then \
    DEBIAN_FRONTEND=noninteractive apt-get update --allow-releaseinfo-change && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-broken libasound2 procps libgbm1 /app/momentum.deb && \
    rm -f /app/momentum.deb ; \
    for i in Downloads nzb tmp ; do mkdir -p /opt/momentum/Momentum/$i && touch /opt/momentum/Momentum/$i/.lockdir ; done ; \
    chown -R mms:mms /opt/momentum/ ; \
    chown -R root:mms /opt/momentum/Momentum/ ; \
    sed -i '/^Exec.*momentum-prod/d' /usr/share/applications/momentum-prod.desktop ; \
    echo 'Exec=env HOME=/opt/momentum /opt/Momentum/momentum-prod --no-sandbox' >> /usr/share/applications/momentum-prod.desktop ; \
    ln -s /usr/share/applications/momentum-prod.desktop /root/Desktop/ ; \
  else \
    unset RUN_MOMENTUM ; \
  fi

## setup samba
##------------------------------------------------------------------------------
RUN set -ex ; \
  if [ ${BUILD_SAMBA:-0} -gt 0 2>/dev/null ] ; then \
    DEBIAN_FRONTEND=noninteractive apt-get install -y smbclient cifs-utils heimdal-clients samba --fix-broken ; \
    useradd -m -s /sbin/nologin guest ; \
    chmod o+t /app/samba/usershares ; \
    echo "alias smbpasswd='smbpasswd -c /app/samba/config/samba.conf'" >> /etc/skel/.bash_aliases ; \
    echo "alias testparm='testparm /app/samba/config/samba.conf -v -s'" >> /etc/skel/.bash_aliases ; \
    cp /etc/skel/.bash_aliases /root/.bash_aliases ; \
    mv /app/samba/add-samba-user /usr/local/bin/ && chmod 755 /usr/local/bin/add-samba-user ; \
  else \
    unset RUN_SAMBA ; \
  fi

## setup firefox
##------------------------------------------------------------------------------
RUN set -ex ; \
  if [ ${BUILD_FIREFOX:-0} -gt 0 2>/dev/null ] ; then \
    DEBIAN_FRONTEND=noninteractive apt-get install firefox-esr firefox-esr-*de* -y ; \
    ln -s /usr/share/applications/firefox-esr.desktop /root/Desktop/ ; \
    sed -i '/Exec=.*/d' /usr/share/applications/firefox-esr.desktop ; \
    echo 'Exec=/usr/lib/firefox-esr/firefox-esr --profile /opt/momentum/.mozilla %u' >> /usr/share/applications/firefox-esr.desktop ; \
    mkdir -p /opt/momentum/.mozilla ; \
  else \
    unset RUN_FIREFOX ; \
  fi

## setup vpn-unlimited
##------------------------------------------------------------------------------
RUN set -ex ; \
  if [ ${BUILD_VPNUNLIMIT:-0} -gt 0 2>/dev/null ] ; then \
    echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections ; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-broken resolvconf ; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-broken libboost-filesystem-dev libboost-locale-dev /app/vpn-unlimited.deb ; \
    rm -f /app/vpn-unlimited.deb ; \
    sed -i '/Exec=.*/d' /usr/share/applications/vpn-unlimited.desktop ; \
    ln -s /usr/share/applications/vpn-unlimited.desktop /root/Desktop/ ; \
    echo 'Exec=vpn-unlimited --no-sandbox' >> /usr/share/applications/vpn-unlimited.desktop ; \
  else \
    unset RUN_VPNUNLIMIT ; \
  fi

## atleast
##------------------------------------------------------------------------------
RUN DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y && \
  DEBIAN_FRONTEND=noninteractive apt-get clean --dry-run updatedb

CMD ["/docker-entrypoint.sh"]
VOLUME ["/opt/mediaserver/data","/opt/momentum","/app","/docker-entrypoint.d"]
WORKDIR /opt/momentum/
EXPOSE 8080 22 5900 80 443
