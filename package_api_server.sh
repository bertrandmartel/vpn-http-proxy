#!/bin/bash

set -e

zip -r api-server-proxy.zip api-server-proxy
cp api-server-proxy.zip gateway-raspberry/playbook/roles/api_proxy/files/