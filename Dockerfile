#
# Dockerfile for snell
#

FROM alpine:latest

ARG GLIBC_VER="2.34-r0"
ENV GLIBC_URL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk
ENV GLIBCBIN_URL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk
ENV SNELL_URL https://github.com/surge-networks/snell/releases/download/v3.0.1/snell-server-v3.0.1-linux-amd64.zip

RUN set -ex \
    && apk add --update --no-cache \
        libstdc++ \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget $GLIBC_URL \
    && wget $GLIBCBIN_URL \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && rm -rf glibc* \
    && wget -q -O /snell.zip $SNELL_URL \
    && mkdir /etc/snell \
    && unzip /snell.zip -d /etc/snell \
    && rm -rf /snell.zip \
    && rm -rf /etc/apk/keys/sgerrand.rsa.pub \
    && rm -rf /var/cache/apk

WORKDIR /etc/snell

COPY docker-entrypoint.sh /entrypoint.sh

ENV PATH /etc/snell:$PATH

ENV SERVER_PORT 6160
ENV PSK=
ENV OBFS http

EXPOSE ${SERVER_PORT}/tcp
EXPOSE ${SERVER_PORT}/udp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["snell-server", "-c", "snell-server.conf"]
