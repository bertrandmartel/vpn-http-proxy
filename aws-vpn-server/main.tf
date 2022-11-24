data "aws_region" "current" {}

# vpn keys & secrets
module "keys" {
  source                      = "./keys"
  vpn_keys_client_secret_name = var.vpn_keys_client_secret_name
  vpn_keys_server_secret_name = var.vpn_keys_server_secret_name
  vpn_server_dns              = var.vpn_server_dns
  vpn_clients                 = var.vpn_clients
}

# Security groups
module "sg" {
  source                 = "./sg"
  vpc_id                 = var.vpc_id
  prefix                 = var.prefix
  common_tags            = var.common_tags
  vpn_server_allowed_ips = var.vpn_server_allowed_ips
}

# VPN server load balancer
module "lb" {
  source            = "./lb"
  prefix            = var.prefix
  common_tags       = var.common_tags
  public_subnets    = var.public_subnets
  security_group_id = module.sg.vpn_server_sg.id
  vpc_id            = var.vpc_id
  instance_id       = module.vpn_server.instance.id
  depends_on = [
    module.vpn_server.instance,
    module.sg.vpn_server_sg
  ]
}

# open vpn server
module "vpn_server" {
  source                   = "./vpn"
  vpn_server_ec2_name      = var.vpn_server_ec2_name
  vpn_client               = false
  security_group_id        = module.sg.vpn_server_sg.id
  vpc_id                   = var.vpc_id
  prefix                   = var.prefix
  instance_profile         = module.iam.server_profile
  permissions_boundary     = var.permissions_boundary
  ec2_ami                  = var.ec2_vpn_ami
  ec2_instance_type        = var.ec2_vpn_instance_type
  public_subnet            = var.public_subnet
  common_tags              = var.common_tags
  root_block_volume_config = var.root_block_volume_config
  ca_cert_md5              = module.keys.ca_cert_md5
  public_cert_md5          = module.keys.server_public_md5
  private_cert_md5         = module.keys.server_private_md5

  playbook_sha = data.archive_file.playbook.output_sha
  ssm_doc_sha  = module.ssm.aws_ssm_document.hash

  depends_on = [
    module.keys.vpn_server_secret,
    module.sg.vpn_server_sg,
    module.ssm.aws_ssm_association,
    module.ssm.aws_ssm_document,
    module.iam.server_profile
  ]
}

# S3 storage
module "s3" {
  source      = "./s3"
  prefix      = var.prefix
  common_tags = var.common_tags
}

# ssm (provisioning)
module "ssm" {
  source     = "./ssm"
  prefix     = var.prefix
  aws_region = data.aws_region.current.name

  vpn_server_secret           = module.keys.vpn_server_secret
  vpn_keys_server_secret_name = var.vpn_keys_server_secret_name
  vpn_server_dns              = var.vpn_server_dns

  s3_kms_key_id          = module.s3.kms.key_id
  playbook_bucket_name   = module.s3.bucket_playbook.id
  association_depends_on = [module.s3.playbook_files]
  common_tags            = var.common_tags
  depends_on = [
    module.s3.kms,
    module.s3.bucket_playbook,
    module.s3.playbook_files,
    module.keys.vpn_server_secret
  ]
}

# iam role for EC2 instances
module "iam" {
  source               = "./iam"
  prefix               = var.prefix
  permissions_boundary = var.permissions_boundary
  s3_policy            = module.s3.policy
  vpn_policy_server    = module.ssm.policy_server
  depends_on = [
    module.ssm.policy_client,
    module.ssm.policy_server,
    module.s3.policy
  ]
}

# DNS
module "route53" {
  source                     = "./route53"
  dns_zone                   = var.dns_zone
  vpn_server_dns             = var.vpn_server_dns
  route53_geolocation_policy = var.route53_geolocation_policy
  route53_identifier         = var.route53_identifier
  public_ip                  = module.vpn_server.public_ip
}

# archive of playbook to monitor changes 
data "archive_file" "playbook" {
  type        = "zip"
  source_dir  = "playbook/"
  output_path = "playbook.zip"
}