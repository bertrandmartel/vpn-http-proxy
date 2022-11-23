# OpenVPN through client gateway

* The main idea is to get Internet access through a local Raspberry PI (as gateway) using an OpenVPN server hosted on AWS.
* [TODO] use vpn connection on a subnet using custom nat instance

This project implements all parts of this architecture:

* AWS ressources:
  *  an OpenVPN server 
  * a Classic Load Balancer
* Raspberry PI resources:
  * an OpenVPN client
* Kubernetes resources (helm):
  * a pod running in a Kubernetes cluster with openvpn client

Keys are generated using [Easy RSA v3](https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto) 

## Project structure

| directory | description |
|---------|-------|
| aws-vpn-kube-client | helm chart for Open VPN client |
| aws-vpn-server | terraform project for deploying OpenVPN server / classic load balancer / AWS secrets... |
| docker-image | docker build of the Open VPN client |
| easy-rsa | easy rsa scripts used to generate open vpn certificates | 
| gateway-raspberry | ansible playbook used to provision openvpn client on the Raspberry PI |

## 1 - Generate OpenVPN keys :key:

* edit `easy-rsa-init-vars` file with certificate metadata
* edit `.easy-rsa` file if necessary (server & clients name, directory naming...)

```bash
cd easy-rsa
./init-keys.sh
```

## 2 - Deploy AWS infrastructure using terraform

* Update `terraform.tfvars` in `aws-vpn-server/terraform.tfvars`

* Deploy:

```bash
terraform -chdir=aws-vpn-server/ init
terraform -chdir=aws-vpn-server/ plan -var-file="../terraform.tfvars"
terraform -chdir=aws-vpn-server/ apply -var-file="../terraform.tfvars"
```
## 4 - Deploy helm chart on your kubernetes cluster

* Update `values.yml` in `aws-vpn-kube-client/values.yml`

* Deploy the chart:

```bash
helm install vpn-client-proxy -n demo aws-vpn-kube-client/helm -f values-custom.yml
```

* If you modify the chart, you would need to upgrade:

```bash
helm upgrade vpn-client-proxy -n demo aws-vpn-kube-client/helm -f values-custom.yml
```

## 5 - Deploy to raspberry PI

On Raspberry PI: 

* add `easy-rsa/easy-rsa-src/ssh/pi_ssh.pub` to authorized_keys file under `.ssh/authorized_keys`

Then:

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ./gateway-raspberry/hosts -e "vpn_server_host=changeme.example.com"  ./gateway-raspberry/playbook/vpn.yaml --ask-pass
```

## Debug

* Ansible playbook logs on EC2 - Open VPN server

SSM debug log location:

```bash
cat /var/lib/amazon/ssm/[INSTANCE_ID]/document/orchestration/[DOCUMENT_ID]/awsrunShellScript/runShellScript/stdout
```

Run the playbook on the EC2 (for debugging):

```bash
ansible-playbook -i localhost -c local -v -e "SSM=True aws_region=eu-west-3 vpn_keys_server_secret_name=some-secret" vpn-http-proxy.yaml
```

* connect to Raspberry PI

```bash
ssh -i ../easy-rsa/easy-rsa-src/ssh/ec2_ssh pi@raspberrypi.local
```

## OpenVPN custom thing

On Raspberry PI, the ansible playbook takes the following into account:

* enable ip forwarding
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

* add necessary postrouting iptable rule

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

To show current nat iptables rules:

```bash
iptables -nvL -t nat
```