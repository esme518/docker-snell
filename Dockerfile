#
# Dockerfile for snell
#

FROM alpine as source

ARG URL=https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/48125610
ARG SNELL_VER=4.0.1

WORKDIR /root

RUN set -ex \
    && if [ "$(uname -m)" == aarch64 ]; then \
           export PLATFORM='linux-aarch64'; \
       elif [ "$(uname -m)" == x86_64 ]; then \
           export PLATFORM='linux-amd64'; \
       fi \
    && export SNELL_URL=https://dl.nssurge.com/snell/snell-server-v${SNELL_VER}-${PLATFORM}.zip \
    && apk add --update --no-cache curl \
    && wget -O glibc.apk $(curl -s $URL | grep browser_download_url | egrep -o 'http.+glibc-\d.*\.apk') \
    && wget -O glibc-bin.apk $(curl -s $URL | grep browser_download_url | egrep -o 'http.+glibc-bin-\d.*\.apk') \
    && wget -O snell.zip $SNELL_URL \
    && unzip snell.zip -d /etc/snell \
    && rm -rf snell.zip

FROM alpine
COPY --from=source /root/*.apk /root/
COPY --from=source /etc/snell /etc/snell

WORKDIR /root

RUN set -ex \
    && wget -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && apk add --update --no-cache --force-overwrite \
        glibc.apk \
        glibc-bin.apk \
        libstdc++ \
        tini \
    && rm -rf *.apk /etc/apk/keys/sgerrand.rsa.pub \
    && rm -rf /var/cache/apk

WORKDIR /etc/snell

COPY docker-entrypoint.sh /entrypoint.sh

ENV PATH /etc/snell:$PATH

ENV INTERFACE 0.0.0.0
ENV PORT 6160
ENV PSK=
ENV IPV6 false

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["snell-server", "-c", "snell-server.conf"]
