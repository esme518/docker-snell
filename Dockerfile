#
# Dockerfile for snell
#

FROM alpine as source

ARG SNELL_VER=4.0.1

WORKDIR /root

RUN set -ex \
    && if [ "$(uname -m)" == aarch64 ]; then \
           export PLATFORM='linux-aarch64'; \
       elif [ "$(uname -m)" == x86_64 ]; then \
           export PLATFORM='linux-amd64'; \
       fi \
    && export SNELL_URL=https://dl.nssurge.com/snell/snell-server-v${SNELL_VER}-${PLATFORM}.zip \
    && wget -O snell.zip $SNELL_URL \
    && unzip snell.zip -d /etc/snell \
    && rm -rf snell.zip

FROM cgr.dev/chainguard/wolfi-base
COPY --from=source /etc/snell /etc/snell

COPY docker-entrypoint.sh /entrypoint.sh

RUN set -ex \
    && apk add --update --no-cache \
        libstdc++ \
        tini \
    && chown -R nonroot.nonroot /etc/snell \
    && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /etc/snell
ENV PATH /etc/snell:$PATH

ENV INTERFACE 0.0.0.0
ENV PORT 6160
ENV PSK=
ENV IPV6 false

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["snell-server", "-c", "snell-server.conf"]
