#!/bin/sh

if [ ! -f "/etc/snell/snell-server.conf" ]; then
        if [ -z "$PSK" ]; then
                PSK=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
        fi
        cat > /etc/snell/snell-server.conf <<EOF
[snell-server]
listen = 0.0.0.0:${SERVER_PORT}
psk = ${PSK}
obfs = ${OBFS}
EOF
        cat /etc/snell/snell-server.conf
fi

exec "$@"
