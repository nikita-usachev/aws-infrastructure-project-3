variable "prefix" {
  type = string
}

variable "suffix" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type    = string
  default = null
}

variable "local_ipv4_network_cidr" {
  type    = string
  default = null
}

variable "remote_ipv4_network_cidr" {
  type    = string
  default = null
}

variable "use_attached_vpg" {
  type    = bool
  default = false
}

variable "static_routes" {
  type    = list(string)
  default = []
}

variable "propagation_subnets" {
  type    = list(string)
  default = []
}

variable "ip_address" {
  type    = string
  default = null
}

variable "vpc_id" {
  type = string
}

variable "nat_route_table_id" {
}

variable "nat_subnet_id" { 
  type = list(string)
}

variable "tunnel1_preshared_key" {
  type = string
  default = ""
}

variable "tunnel1_inside_cidr" {
  type = string
  default = ""
}

variable "tunnel1_ike_versions" {
  type = list(any)
  default = []
}

variable "tunnel1_phase1_dh_group_numbers" {
  type = list(any)
  default = []
}

variable "tunnel1_phase1_encryption_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel1_phase1_integrity_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel1_phase2_dh_group_numbers" {
  type = list(any)
  default = []
}

variable "tunnel1_phase2_encryption_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel1_phase2_integrity_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel1_startup_action" {
  type = string
  default = ""
}

variable "tunnel2_preshared_key" {
  type = string
  default = ""
}

variable "tunnel2_inside_cidr" {
  type = string
  default = ""
}

variable "tunnel2_ike_versions" {
  type = list(any)
  default = []
}

variable "tunnel2_phase1_dh_group_numbers" {
  type = list(any)
  default = []
}

variable "tunnel2_phase1_encryption_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel2_phase1_integrity_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel2_phase2_dh_group_numbers" {
  type = list(any)
  default = []
}

variable "tunnel2_phase2_encryption_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel2_phase2_integrity_algorithms" {
  type = list(any)
  default = []
}

variable "tunnel2_startup_action" {
  type = string
  default = ""
}

variable "tags" {
  default = {}
}

locals {
  common_tags = {
    Environment   = var.environment
    Name          = "${var.prefix}${var.suffix}"
    ProvisionedBy = "terraform"
  }
  tags = merge(var.tags, local.common_tags)
}
