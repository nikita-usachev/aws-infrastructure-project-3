# vpc

resource "aws_vpc" "default" {
  count                = var.enabled ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-vpc" })
}

# internet gateway

resource "aws_internet_gateway" "default" {
  count  = var.enabled ? 1 : 0
  vpc_id = aws_vpc.default[0].id

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-igw", Component = "igw" })
}

# elastic ip

resource "aws_eip" "nat" {
  count  = var.enabled && var.private_enabled && var.nat_enabled ? length(var.avail_zones) : 0
  domain = "vpc"
}

# subnets

resource "aws_subnet" "public" {
  count                   = var.enabled ? length(var.avail_zones) : 0
  vpc_id                  = aws_vpc.default[0].id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.avail_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-public-subnet-${element(var.avail_zones, count.index)}" })
}

resource "aws_subnet" "private" {
  count                   = var.enabled && var.private_enabled ? length(var.avail_zones) : 0
  vpc_id                  = aws_vpc.default[0].id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.avail_zones, count.index)
  map_public_ip_on_launch = false

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-private-subnet-${element(var.avail_zones, count.index)}" })
}

resource "aws_subnet" "nat_subnet" {
  vpc_id                  = aws_vpc.default[0].id
  cidr_block              = var.nat_subnet_cidr
  availability_zone       = var.avail_zones[0]
  map_public_ip_on_launch = false

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-nat-instance-subnet" })
}

# nat gateway

resource "aws_nat_gateway" "default" {
  count         = var.enabled && var.private_enabled && var.nat_enabled ? length(var.avail_zones) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-natgw-${element(var.avail_zones, count.index)}", Component = "nat" })
}

# routes

resource "aws_route_table" "public" {
  count  = var.enabled ? length(var.avail_zones) : 0
  vpc_id = aws_vpc.default[0].id

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-public-route-table-${element(var.avail_zones, count.index)}" })
}

resource "aws_route_table" "private" {
  count  = var.enabled && var.private_enabled ? length(var.avail_zones) : 0
  vpc_id = aws_vpc.default[0].id

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-private-route-table-${element(var.avail_zones, count.index)}" })
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.default[0].id

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-nat-instance-route-table" })
}

resource "aws_route" "public" {
  count                  = var.enabled ? length(var.avail_zones) : 0
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default[0].id
}

resource "aws_route" "private" {
  count                  = var.enabled && var.private_enabled && var.nat_enabled ? length(var.avail_zones) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[count.index].id
}

resource "aws_route" "private_natg" {
  count                  = var.enabled && var.private_enabled && var.nat_enabled ? length(var.avail_zones) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = var.enabled ? length(var.avail_zones) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.enabled && var.private_enabled ? length(var.avail_zones) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "nat" {
  subnet_id      = aws_subnet.nat_subnet.id
  route_table_id = aws_route_table.nat.id
}
