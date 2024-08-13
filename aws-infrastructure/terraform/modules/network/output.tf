output "vpc_id" {
  value = join("", aws_vpc.default.*.id)
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "nat_subnet_id" {
  value = aws_subnet.nat_subnet.id
}

output "public_route_table_ids" {
  value = join(",", aws_route_table.public.*.id)
}

output "private_route_table_ids" {
  value = join(",", aws_route_table.private.*.id)
}

output "nat_route_table_ids" {
  value = aws_route_table.nat.id
}
