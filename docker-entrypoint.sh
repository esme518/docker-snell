#!/bin/sh
set -e

if [ ! -f "/etc/snell/snell-server.conf" ]; then
        if [ -z "$PSK" ]; then
                PSK=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
        fi
        cat > /etc/snell/snell-server.conf <<EOF
[snell-server]
listen = ${INTERFACE}:${PORT}
psk = ${PSK}
ipv6 = ${IPV6}
EOF
        cat /etc/snell/snell-server.conf
fi

exec "$@"
