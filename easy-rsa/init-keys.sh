#!/bin/bash

set -e

usage() { echo "Usage: $0 -c client1,client2,client3" 1>&2; exit 1; }

while getopts ":c:" o; do
    case "${o}" in
        c)
            client_str=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${client_str}" ]; then
    usage
fi

IFS=', ' read -r -a clients <<< "$client_str"

. .easy-rsa

easy_rsa_release="$EASY_RSA_RELEASE"
easy_rsa_var_server_name="$EASY_RSA_SERVER_NAME"
easy_rsa_var_client_gateway_name="$EASY_RSA_CLIENT_GATEWAY_NAME"

easy_rsa_dir="easy-rsa-src"
easy_rsa_var_file="easy-rsa-init-vars"

if [ "$1" == "destroy" ]; then
    rm -rf $easy_rsa_dir
    echo "removing easy rsa directory..."
    exit 0
fi

if [ ! -f "$easy_rsa_var_file" ]; then
    echo "var file is missing: $easy_rsa_var_file"
    exit 0
fi

messages=()
if [ ! -d "$easy_rsa_dir" ]; then
    echo "downloading easy rsa v$easy_rsa_release..."
    wget -q "https://github.com/OpenVPN/easy-rsa/releases/download/v$easy_rsa_release/EasyRSA-$easy_rsa_release.tgz"
    tar -xf "EasyRSA-$easy_rsa_release.tgz"
    mv "EasyRSA-$easy_rsa_release/" "$easy_rsa_dir/"; rm -f "EasyRSA-$easy_rsa_release.tgz"
else
    echo "Easy RSA existing on local machine"
fi

echo "Easy RSA location: $easy_rsa_dir"
cd $easy_rsa_dir
export EASYRSA_BATCH=1

if [ ! -d "pki" ]; then
    echo "PKI not existing, creating PKI..."
    ./easyrsa init-pki
else
    echo "PKI existing on local machine"
fi

echo "loading easy rsa vars..."
cp ../$easy_rsa_var_file pki/vars

if [ ! -f "pki/ca.crt" ]; then
    ./easyrsa build-ca nopass
else
    echo "CA already existing on local machine"
fi

if [ ! -d pki/issued ] || [ ! -f pki/issued/$easy_rsa_var_server_name.crt ] ; then
    echo "generating server certificate..."
    ./easyrsa build-server-full $easy_rsa_var_server_name nopass >> easy_rsa.log
else
    echo "server certificate already existing on local machine"
fi

if [ ! -d pki/issued ] || [ ! -f pki/issued/$easy_rsa_var_client_gateway_name.crt ] ; then
    echo "generating gateway client certificate..."
    ./easyrsa build-client-full $easy_rsa_var_client_gateway_name nopass >> easy_rsa.log
else
    echo "gateway client certificate already existing on local machine"
fi

for client in "${clients[@]}"
do
   echo "checking certificate for $client..."
    if [ ! -d pki/issued ] || [ ! -f pki/issued/$client.crt ] ; then
        echo "generating aws client certificate..."
        ./easyrsa build-client-full $client nopass >> easy_rsa.log
    else
        echo "aws client certificate already existing on local machine"
    fi
done

if [ ! -f dh2048.pem ]; then
    openssl dhparam -out dh2048.pem 2048
else
    echo "dh already existing on local machine"
fi

if [ ! -d "ssh" ]; then
    mkdir -p ssh
else
    echo "ssh directory already exists"
fi

if [ ! -f "ssh/pi_ssh" ]; then
    ssh-keygen -b 4096 -t rsa -N "" -f $(pwd)/ssh/pi_ssh
else
    echo "ssh key already existing on local machine"
fi