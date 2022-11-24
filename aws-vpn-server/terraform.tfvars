# VPC id used
vpc_id = "vpc-xxxxxxx"

# tags used on AWS resources that support the tag property
common_tags = {
  "service" : "vpn"
}

# open vpn server - ec2 volume configuration
root_block_volume_config = {
  volume_type = "gp2"
  volume_size = 10
}

# boundary used to create roles
permissions_boundary = "arn:aws:iam::ACCOUNT_NUM:policy/POLICY"

# ami image used for open vpn server EC2 (amazon linux 2)
ec2_vpn_ami = "ami-0f5094faf16f004eb"

# instance type used for open vpn server EC2
ec2_vpn_instance_type = "t2.medium"

# list of subnets used to instanciate classic load balancer
public_subnet = "subnet-xxxxxxxxxx"

# list of subnets used to instanciate classic load balancer
public_subnets = [
  "subnet-xxxxxxxxxx",
  "subnet-xxxxxxxxxx",
  "subnet-xxxxxxxxxx"
]

vpn_server_ec2_name = "vpn-server"

# dns zone name (example.com)
dns_zone = "example.com"

# full open vpm server hostname (vpn.example.com)
vpn_server_dns = "vpn.example.com"

# geolocation policy used to restrict by country
route53_geolocation_policy = {
  country = "FR"
}
# route53 identifier, this is required when using geolocation
route53_identifier = "secure"

# list of IPs cidr allowed to access open vpn server
vpn_server_allowed_ips = [
  "XXX.XXX.XXX.X/32", 
]

# name of AWS secret holding open vpn server certificates. This is used to provision those on EC2 instance
vpn_keys_server_secret_name = "vpn-server-secret"

# name of AWS secret holding open vpn client certificates, this is for the AWS open vpn client, not Raspberry PI open vpn client.
# This is then used as an ExternalSecret in your kubernetes template/helm chart, 
# which can be used along with kubernetes operator external-secrets using AWS secrets provider.
vpn_keys_client_secret_name = "vpn-client-secret"

vpn_clients = [
  "test_client",
  "aws_client"
]