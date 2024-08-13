variable "enabled" {
  default = false
}

variable "private_enabled" {
  default = false
}

variable "nat_enabled" {
  default = true
}

variable "environment" {
}

variable "prefix" {
}

variable "suffix" {
  default = ""
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(any)
  default = []
}

variable "private_subnet_cidrs" {
  type    = list(any)
  default = []
}

variable "nat_subnet_cidr" {
  type    = string
  default = ""
}

variable "avail_zones" {
  default = 1
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
