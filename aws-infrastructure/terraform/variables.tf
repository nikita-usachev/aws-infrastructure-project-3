variable "region" {
  default = "us-east-2"
}

variable "prefix" {
  default = "app"
}

variable "environment" {
  default = null
}

variable "instance_ami_owner" {
  default = ""
}

variable "instance_ami_pattern" {
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "key_name" {
}

variable "key_path_public" {
  default = "~/.ssh/id_rsa.pub"
}

variable "key_path_private" {
  default = "~/.ssh/id_rsa"
}

variable "network_enabled" {
  default = false
}

variable "vpc_cidr" {
  default = null
}

variable "private_subnet_cidrs" {
  default = null
}

variable "public_subnet_cidrs" {
  default = null
}

variable "public_key" {
  default = null
}

variable "nat_subnet_cidr" {
}

variable "vpn_enabled" {
  default = true
}

variable "vpn_client_cidr" {
  default = ""
}

variable "vpn_clients" {
  default = []
}

variable "external_sg_list" {
  type    = string
  default = ""
}

variable "external_ip_list" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "external_port_list" {
  type    = list(any)
  default = [80, 443]
}

variable "az_count" {
  default = 1
}

variable "az_count_network" {
  default = 1
}

variable "private" {
  default = false
}

variable "private_nat" {
  default = true
}

variable "vpc_id" {
  default = null
}

variable "tunnel1_preshared_key" {
  type    = string
  default = ""
}

variable "tunnel1_inside_cidr" {
  type    = string
  default = ""
}

variable "tunnel1_ike_versions" {
  type    = list(any)
  default = []
}

variable "tunnel1_phase1_dh_group_numbers" {
  type    = list(any)
  default = []
}

variable "tunnel1_phase1_encryption_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel1_phase1_integrity_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel1_phase2_dh_group_numbers" {
  type    = list(any)
  default = []
}

variable "tunnel1_phase2_encryption_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel1_phase2_integrity_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel1_startup_action" {
  type    = string
  default = ""
}

variable "tunnel2_preshared_key" {
  type    = string
  default = ""
}

variable "tunnel2_inside_cidr" {
  type    = string
  default = ""
}

variable "tunnel2_ike_versions" {
  type    = list(any)
  default = []
}

variable "tunnel2_phase1_dh_group_numbers" {
  type    = list(any)
  default = []
}

variable "tunnel2_phase1_encryption_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel2_phase1_integrity_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel2_phase2_dh_group_numbers" {
  type    = list(any)
  default = []
}

variable "tunnel2_phase2_encryption_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel2_phase2_integrity_algorithms" {
  type    = list(any)
  default = []
}

variable "tunnel2_startup_action" {
  type    = string
  default = ""
}

variable "ipsec_connections" {
  type = list(object({
    name             = string
    ip_address       = optional(string)
    local_cidr       = optional(string)
    remote_cidr      = optional(string)
    static_routes    = optional(list(string))
    use_attached_vpg = optional(bool)
  }))
  default = []
}

variable "ec2_instances" {
  type    = map(any)
  default = {}
}

# variable "ec2_instances" {
#   type = list(object({
#     type             = optional(string)
#     disk_size        = optional(string)
#   }))
#   default = []
# }

locals {
  environment = var.environment != null ? var.environment : "${terraform.workspace}"
  suffix      = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
}
