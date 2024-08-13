# data

data "aws_vpc" "selected" {
  id      = var.vpc_id
  default = var.vpc_id != null ? false : true
}

data "aws_route_table" "selected" {
  count     = length(var.propagation_subnets)
  subnet_id = var.propagation_subnets[count.index]
}

data "aws_vpn_gateway" "selected" {
  count           = var.use_attached_vpg ? 1 : 0
  attached_vpc_id = data.aws_vpc.selected.id
}

# vpn

resource "aws_customer_gateway" "default" {
  bgp_asn    = 65000
  ip_address = var.ip_address
  type       = "ipsec.1"
  tags       = var.name != null ? merge(local.tags, { Name = "${local.common_tags.Name}-${var.name}" }) : local.tags
}

resource "aws_vpn_connection" "default" {
  customer_gateway_id                  = aws_customer_gateway.default.id
  type                                 = "ipsec.1"
  local_ipv4_network_cidr              = var.local_ipv4_network_cidr
  remote_ipv4_network_cidr             = var.remote_ipv4_network_cidr
  static_routes_only                   = true
  transit_gateway_id                   = aws_ec2_transit_gateway.transit_gateway.id
  
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

  tags                          = var.name != null ? merge(local.tags, { Name = "${local.common_tags.Name}-${var.name}" }) : local.tags
}

# transit gateway

resource "aws_ec2_transit_gateway" "transit_gateway" {
  description                     = "Transit Gateway that enables connection between AWS VPC and other (with the same CIDR block) Network"
  amazon_side_asn                 = 64512
  default_route_table_propagation = "disable"
  tags                            = var.name != null ? merge(local.tags, { Name = "${local.common_tags.Name}-tgw" }) : local.tags
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_vpc_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = var.vpc_id
  subnet_ids         = var.nat_subnet_id
  tags               = var.name != null ? merge(local.tags, { Name = "${local.common_tags.Name}-tgw-vpc-attachment" }) : local.tags
}

# routes

resource "aws_ec2_transit_gateway_route_table" "transit_gateway_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  tags               = var.name != null ? merge(local.tags, { Name = "${local.common_tags.Name}-transit-gateway-route-table" }) : local.tags
}

resource "aws_ec2_transit_gateway_route" "vpc_route" {
  destination_cidr_block         = "170.31.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route" "vpn_route" {
  destination_cidr_block         = "170.31.0.0/16"
  transit_gateway_attachment_id  = aws_vpn_connection.default.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc_route_table_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpn_route_table_association" {
  transit_gateway_attachment_id  = aws_vpn_connection.default.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit_gateway_route_table.id
}

# route for route table

resource "aws_route" "nat_transit_gateway" {
  route_table_id         = var.nat_route_table_id
  destination_cidr_block = "170.31.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.transit_gateway.id
}
