FROM mstorll/novnc:1.0

ARG USER1=marko
ARG PASS1
ARG USER2=dari
ARG PASS2

COPY .vimrc /root/.vimrc
COPY dari.conf  /app/samba/config/dari.conf
COPY marko.conf /app/samba/config/marko.conf

RUN if [ -z "$USER1" -o  -z "${PASS1:-#Password.1234}" ] ; then exit 1 ; fi 
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -y ; \
  add-samba-user "root" "$(cat /dev/urandom | tr -cd "a-zA-Z0-9" | head -c 32)" ; \
  add-samba-user "mms"  "$(cat /dev/urandom | tr -cd "a-zA-Z0-9" | head -c 32)" ; \
  add-samba-user "$USER1" "${PASS1:-#Password.1234}" ; \
  add-samba-user "$USER2" "${PASS2:-#Password.1234}" ; \
  sed -i "/^$USER1/d" /app/samba/config/usermap.txt ; echo "$USER1 = MicrosoftAccount\\$USER1 $USER1" >> /app/samba/config/usermap.txt ; \
  sed -i "/^$USER2/d" /app/samba/config/usermap.txt ; echo "$USER2 = MicrosoftAccount\\$USER2 $USER2" >> /app/samba/config/usermap.txt ; \
  echo "   include = /app/samba/config/dari.conf" >> /app/samba/config/samba.conf ; \
  echo "   include = /app/samba/config/marko.conf" >> /app/samba/config/samba.conf ; \
  xdir="/opt/mediaserver/data/.homedrive/$(echo "${USER1}" | sed 's/./\U&/')" ; \
  echo "$xdir" && sleep 6 ; \
    mkdir -p "$xdir" && touch $xdir/es_funktioniert.txt ; chown -R ${USER1} "$xdir" && touch $xdir/.lockdir && chmod 400 $xdir/.lockdir ; \
  xdir="/opt/mediaserver/data/.homedrive/$(echo "${USER2}" | sed 's/./\U&/')" ; \
    mkdir -p "$xdir" && touch $xdir/es_funktioniert.txt ; chown -R ${USER1} "$xdir" && touch $xdir/.lockdir && chmod 400 $xdir/.lockdir ; \
  sed -i '/^[[:blank:]]*log level/s/log level.*/log level = 2  passdb:5 auth:5/g' /app/samba/config/samba.conf ; \
  usermod -u 21011970 marko ; \
  updatedb ; \
  apt clean
