#!/bin/bash

set -e

CA_CERT_FILE=/etc/secrets/ca_cert
PRIVATE_CERT_FILE=/etc/secrets/private_cert
PUBLIC_CERT_FILE=/etc/secrets/public_cert

if [ ! -f $CA_CERT_FILE ]; then
    echo "file $CA_CERT_FILE doesn't exist"
    exit 1 
fi
if [ ! -f $PRIVATE_CERT_FILE ]; then
    echo "file $PRIVATE_CERT_FILE doesn't exist"
    exit 1
fi
if [ ! -f $PUBLIC_CERT_FILE ]; then
    echo "file $PUBLIC_CERT_FILE doesn't exist"
    exit 1
fi
if [ -z $VPN_SERVER_HOST ]; then
    echo "var VPN_SERVER_HOST is required"
    exit 1
fi

cat $CA_CERT_FILE | base64 -d >> /etc/openvpn/ca.crt
cat $PUBLIC_CERT_FILE | base64 -d >> /etc/openvpn/client.crt
cat $PRIVATE_CERT_FILE | base64 -d >> /etc/openvpn/client.key

envsubst < /etc/openvpn/client.conf.template > /etc/openvpn/client.conf

openvpn --cd /etc/openvpn --config /etc/openvpn/client.conf --script-security 2 > /var/log/openvpn.log &

squid&
nginx -g "daemon off;"&

while true; do sleep 30; done;