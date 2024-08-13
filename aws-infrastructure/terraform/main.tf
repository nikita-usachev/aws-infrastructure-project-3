# provider

provider "aws" {
  region = var.region
}

# data

data "aws_availability_zones" "selected" {}

# key

resource "aws_key_pair" "key_pair" {
  key_name   = "instance-key"
  public_key = file(var.key_path_public)
  lifecycle {
    ignore_changes = [public_key]
  }
}

# network

module "network" {
  source               = "./modules/network"
  enabled              = var.network_enabled
  prefix               = var.prefix
  suffix               = local.suffix
  environment          = local.environment
  vpc_cidr             = var.vpc_cidr
  private_enabled      = var.private
  nat_enabled          = var.private_nat
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  avail_zones          = slice(data.aws_availability_zones.selected.names, 0, var.az_count_network)
  tags = {
    Component = "vpc"
  }
}

module "ipsec" {
  source                   = "./modules/ipsec"
  for_each                 = { for index, key in var.ipsec_connections : key.name => key }
  prefix                   = var.prefix
  suffix                   = local.suffix
  environment              = local.environment
  vpc_id                   = var.network_enabled ? module.network.vpc_id : var.vpc_id
  nat_subnet_id            = [module.network.nat_subnet_id]
  name                     = lookup(each.value, "name")
  ip_address               = lookup(each.value, "ip_address", null)
  local_ipv4_network_cidr  = lookup(each.value, "local_cidr", null)
  remote_ipv4_network_cidr = lookup(each.value, "remote_cidr", null)
  static_routes            = lookup(each.value, "static_routes", null)
  use_attached_vpg         = try(each.value.use_attached_vpg) != null ? each.value.use_attached_vpg : false
  propagation_subnets      = var.network_enabled ? module.network.public_subnet_ids : null
  nat_route_table_id       = module.network.nat_route_table_ids

  tunnel1_preshared_key                = var.tunnel1_preshared_key
  tunnel1_inside_cidr                  = var.tunnel1_inside_cidr
  tunnel1_ike_versions                 = var.tunnel1_ike_versions
  tunnel1_phase1_dh_group_numbers      = var.tunnel1_phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms = var.tunnel1_phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.tunnel1_phase1_integrity_algorithms
  tunnel1_phase2_dh_group_numbers      = var.tunnel1_phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms = var.tunnel1_phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = var.tunnel1_phase2_integrity_algorithms
  tunnel1_startup_action               = var.tunnel1_startup_action
  tunnel2_preshared_key                = var.tunnel2_preshared_key
  tunnel2_inside_cidr                  = var.tunnel2_inside_cidr
  tunnel2_ike_versions                 = var.tunnel2_ike_versions
  tunnel2_phase1_dh_group_numbers      = var.tunnel2_phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms = var.tunnel2_phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = var.tunnel2_phase1_integrity_algorithms
  tunnel2_phase2_dh_group_numbers      = var.tunnel2_phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms = var.tunnel2_phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms  = var.tunnel2_phase2_integrity_algorithms
  tunnel2_startup_action               = var.tunnel2_startup_action
  tags = {
    Component = "ipsec"
  }
}

# NAT instance

module "nat_instance" {
  source                 = "./modules/instances"
  instance_type          = lookup(var.ec2_instances.nat_instance, "type", null)
  instance_disk_size     = lookup(var.ec2_instances.nat_instance, "disk_size", null)
  key_name               = var.key_name
  key_path               = var.key_path_private
  environment            = local.environment
  prefix                 = var.prefix
  suffix                 = "nat-${local.suffix}"
  instance_ami_pattern   = var.instance_ami_pattern
  instance_ami_owner     = var.instance_ami_owner
  ansible_groups         = ["all", "nat"]
  avail_zones            = slice(data.aws_availability_zones.selected.names, 0, var.az_count)
  vpc_id                 = var.network_enabled ? module.network.vpc_id : var.vpc_id
  subnet_ids             = module.network.nat_subnet_id
  public_subnet_cidrs    = module.network.public_subnet_ids
  public_route_table_id  = [module.network.public_route_table_ids]
  private_route_table_id = [module.network.private_route_table_ids]
  nat_route_table_id     = module.network.nat_route_table_ids
  enabled                = var.network_enabled
  private_enabled        = var.private
  nat_enabled            = var.private_nat
  external_ip_list       = var.external_ip_list
  external_port_list     = var.external_port_list
  external_sg_list       = var.external_sg_list
  elastic_ip_enable      = true
  tags = {
    Application = "infra"
  }
  region     = var.region
  depends_on = [module.network]
}

# vpn

module "vpn" {
  source            = "./modules/vpn"
  count             = var.vpn_enabled ? 1 : 0
  region            = var.region
  environment       = local.environment
  prefix            = var.prefix
  suffix            = "-vpn${local.suffix}"
  vpc_id            = var.network_enabled ? module.network.vpc_id : var.vpc_id
  subnet_ids        = var.network_enabled ? slice(module.network.public_subnet_ids, 0, var.az_count) : null
  client_cidr_block = var.vpn_client_cidr
  clients           = var.vpn_clients
  tags = {
    Application = "infra"
    Component   = "vpn"
  }
  depends_on = [module.network]
}

# module "test_instance" {
#   source               = "./modules/instances"
#   instance_type        = lookup(var.ec2_instances.test_instance, "type", null)
#   instance_disk_size   = lookup(var.ec2_instances.test_instance, "disk_size", null)
#   key_name             = var.key_name
#   key_path             = var.key_path_private
#   environment          = local.environment
#   prefix               = var.prefix
#   suffix               = "test-${local.suffix}"
#   instance_ami_pattern = var.instance_ami_pattern
#   instance_ami_owner   = var.instance_ami_owner
#   ansible_groups       = ["all", "test"]
#   avail_zones          = slice(data.aws_availability_zones.selected.names, 0, var.az_count)
#   vpc_id               = var.network_enabled ? module.network.vpc_id : var.vpc_id
#   subnet_ids           = module.network.public_subnet_ids[0]
#   public_subnet_cidrs  = module.network.public_subnet_ids
#   external_ip_list     = var.external_ip_list
#   external_port_list   = var.external_port_list
#   external_sg_list     = var.external_sg_list
#   elastic_ip_enable    = false
#   tags = {
#     Application = "infra"
#   }
#   region     = var.region
#   depends_on = [module.network]
# }
