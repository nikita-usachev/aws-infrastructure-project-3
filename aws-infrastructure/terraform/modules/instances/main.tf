terraform {
  required_providers {
    ansible = {
      source  = "nbering/ansible"
      version = "1.0.4"
    }
  }
}

# data

data "aws_vpc" "selected" {
  id      = var.vpc_id
  default = var.vpc_id != null ? false : true
}

data "aws_ami" "selected" {
  owners = [var.instance_ami_owner]
  filter {
    name   = "name"
    values = [var.instance_ami_pattern]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
}

# elastic ip

resource "aws_eip" "nat_eip" {
  domain   = "vpc"
}

# data disk

resource "aws_ebs_volume" "data" {
  count             = var.data_disk_enable ? 2 : 0
  availability_zone = "us-east-2a"
  size              = var.data_disk_size
  type              = var.data_disk_type

  tags = merge(local.tags, { Name = "${local.common_tags.Name}-${count.index + var.start_index}-data" })
}

resource "aws_volume_attachment" "data" {
  count       = var.data_disk_enable ? 2 : 0
  volume_id   = aws_ebs_volume.data[count.index].id
  instance_id = aws_instance.nat_instance.id
  device_name = "/dev/xvda"
}

# security group

resource "aws_security_group" "nat_gw_instance_sg" {
  vpc_id      = data.aws_vpc.selected.id
  name        = "${local.common_tags.Name}-nat-gw-instance-sg"
  description = "Security group for NAT gateway and TEST instance"
  tags        = merge(local.tags, { Name = "${local.common_tags.Name}-nat-gw-instance-sg" })
}

resource "aws_security_group_rule" "external_cidrs" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = var.external_ip_list
  security_group_id = aws_security_group.nat_gw_instance_sg.id
}

resource "aws_security_group_rule" "external_ports" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_gw_instance_sg.id
}

resource "aws_security_group_rule" "external_security_groups" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = var.external_sg_list
  security_group_id        = aws_security_group.nat_gw_instance_sg.id
}

resource "aws_security_group_rule" "local" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.nat_gw_instance_sg.id
}

resource "aws_security_group_rule" "outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat_gw_instance_sg.id
}

# instances

resource "aws_instance" "nat_instance" {
  ami               = data.aws_ami.selected.id
  instance_type     = var.instance_type
  subnet_id         = var.subnet_ids
  source_dest_check = false
  root_block_device {
    volume_size           = var.instance_disk_size
    delete_on_termination = true
  }
  vpc_security_group_ids = [aws_security_group.nat_gw_instance_sg.id]
  key_name               = var.key_name
  user_data              = "${file("./modules/instances/user_data.sh")}"
  
  lifecycle {
    ignore_changes = [ami, ebs_optimized, user_data]
  }
  tags = merge(local.tags, { Name = "${local.common_tags.Name}-nat-instance" })
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat_eip.id
}

# routes for route tables

resource "aws_route" "private_nat" {
  count                  = var.enabled && var.private_enabled && var.nat_enabled ? length(var.avail_zones) : 0
  route_table_id         = element(var.private_route_table_id, count.index)
  destination_cidr_block = "170.31.0.0/16"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id
}

resource "aws_route" "private_nat_eni" {
  count                  = var.enabled && var.private_enabled && var.nat_enabled ? length(var.avail_zones) : 0
  route_table_id         = element(var.private_route_table_id, count.index)
  destination_cidr_block = "170.31.0.0/16"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id
}

resource "aws_route" "nat_instance" {
  route_table_id         = var.nat_route_table_id
  destination_cidr_block = "170.31.0.0/16"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id
}

resource "aws_route" "public_nat" {
  count                  = var.enabled ? length(var.avail_zones) : 0
  route_table_id         = element(var.public_route_table_id, count.index)
  destination_cidr_block = "170.31.0.0/16"
  network_interface_id   = aws_instance.nat_instance.primary_network_interface_id
}

resource "aws_instance" "test_instance" {
  ami               = data.aws_ami.selected.id
  instance_type     = var.instance_type
  subnet_id         = "subnet-0000"
  source_dest_check = false
  root_block_device {
    volume_size           = var.instance_disk_size
    delete_on_termination = true
  }
  vpc_security_group_ids = [aws_security_group.nat_gw_instance_sg.id]
  key_name               = var.key_name
  
  lifecycle {
    ignore_changes = [ami, ebs_optimized, user_data]
  }
  tags = merge(local.tags, { Name = "${local.common_tags.Name}-test-instance" })
}

# ansible

# resource "ansible_host" "vms" {
#   count              = var.instance_count > 0 ? var.instance_count : 0
#   inventory_hostname = "${local.common_tags.Name}-${count.index + var.start_index}"
#   groups             = var.ansible_groups
#   vars = merge(
#     {
#       ansible_user                 = var.username
#       ansible_ssh_private_key_file = var.key_path != null ? "../terraform/teams/${basename(abspath(path.root))}/${var.key_path}" : null
#       ansible_host                 = var.elastic_ip_enable ? join("", aws_eip.ip.*.public_dns) : var.spot_price == null ? aws_instance.vms[count.index].public_dns != "" ? aws_instance.vms[count.index].public_dns : aws_instance.vms[count.index].private_dns : aws_spot_instance_request.vms[count.index].public_dns != "" ? aws_spot_instance_request.vms[count.index].public_dns : aws_spot_instance_request.vms[count.index].private_dns
#       ansible_ssh_extra_args       = "-o StrictHostKeyChecking=no"
#     },
#     var.ansible_variables
#   )
# }
