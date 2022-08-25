#!/bin/sh
node /etc/server/api-server-proxy/server.js 2 > /var/log/api-server-proxy.log &

# https://serverfault.com/a/833237/321301
if ! kill -0 $! 2>/dev/null; then
    # Return 1 so that systemd knows the service failed to start
    exit 1
fi