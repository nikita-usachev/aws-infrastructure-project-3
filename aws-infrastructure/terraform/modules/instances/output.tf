# output "ansible" {
#   value = ansible_host.vms
# }

# output "instance_endpoint" {
#   value = ansible_host.vms.*.vars.ansible_host
# }

# output "sg_id" {
#   value = join(",", aws_security_group.vms.*.id)
# }

# output "ids" {
#   value = var.spot_price == null ? aws_instance.vms.*.id : aws_spot_instance_request.vms.*.id
# }

# output "role_arn" {
#   value = join(",", aws_iam_role.vms.*.arn)
# }

# output "instance_private_ip" {
#   value = aws_instance.vms.*.private_ip
# }

# output "instance_id" {
#   value = aws_instance.vms.*.id
# }
