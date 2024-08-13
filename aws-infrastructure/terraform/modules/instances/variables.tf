variable "enabled" {
  default = false
}

variable "private_enabled" {
  default = false
}

variable "avail_zones" {
  default = 1
}

variable "nat_enabled" {
  default = true
}

variable "instance_type" {
}

variable "instance_disk_size" {
}

variable "public_subnet_cidrs" {
}

variable "subnet_ids" {
}

variable "public_route_table_id" {
  type = list(any)
}

variable "private_route_table_id" {
  type = list(any)
}

variable "nat_route_table_id" {
}

variable "instance_ami_pattern" {
}

variable "instance_ami_owner" {
}

variable "key_name" {
}

variable "key_path" {
}

variable "vpc_id" {
}

variable "environment" {
}

variable "prefix" {
}

variable "suffix" {
}

variable "start_index" {
  type    = number
  default = 1
}

variable "ansible_groups" {
  type = list(any)
}

variable "ansible_variables" {
  type    = map(any)
  default = {}
}

variable "external_ip_list" {
  default = []
}

variable "external_port_list" {
  default = []
}

variable "external_sg_list" {
  default = ""
}

variable "elastic_ip_enable" {
  type    = bool
  default = false
}

variable "data_disk_enable" {
  type    = bool
  default = false
}

variable "data_disk_size" {
  default = 8
}

variable "data_disk_type" {
  default = "gp2"
}

variable "spot_price" {
  default = null
}

variable "region" {
  default = null
}

variable "tags" {
  default = {}
}

variable "user_data" {
  default = null
}

locals {
  common_tags = {
    Environment   = var.environment
    Name          = "${var.prefix}"
    ProvisionedBy = "terraform"
  }
  tags = merge(var.tags, local.common_tags)
}
