#!/bin/bash

set -e

. .easy-rsa

easy_rsa_release="$EASY_RSA_RELEASE"
easy_rsa_var_server_name="$EASY_RSA_SERVER_NAME"
easy_rsa_var_client_aws_name="$EASY_RSA_CLIENT_AWS_NAME"
easy_rsa_var_client_gateway_name="$EASY_RSA_CLIENT_GATEWAY_NAME"
easy_rsa_var_client_test_name="$EASY_RSA_CLIENT_TEST_NAME"

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

if [ ! -d pki/issued ] || [ ! -f pki/issued/$easy_rsa_var_client_aws_name.crt ] ; then
    echo "generating aws client certificate..."
    ./easyrsa build-client-full $easy_rsa_var_client_aws_name nopass >> easy_rsa.log
else
    echo "aws client certificate already existing on local machine"
fi

if [ ! -d pki/issued ] || [ ! -f pki/issued/$easy_rsa_var_client_gateway_name.crt ] ; then
    echo "generating gateway client certificate..."
    ./easyrsa build-client-full $easy_rsa_var_client_gateway_name nopass >> easy_rsa.log
else
    echo "gateway client certificate already existing on local machine"
fi

# generate test certificate
if [ ! -d pki/issued ] || [ ! -f pki/issued/$easy_rsa_var_client_test_name.crt ] ; then
    echo "generating test client certificate..."
    ./easyrsa build-client-full $easy_rsa_var_client_test_name nopass >> easy_rsa.log
else
    echo "test client certificate already existing on local machine"
fi

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