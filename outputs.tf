data "aws_availability_zones" "available_zone_output" {}

output "availability_zones" {
  value = data.aws_availability_zones.available_zone_output.names
}

output "debug_aws_subnet" {
  value = aws_subnet.pub-subnets
}

output "debug_var_public_subnet" {
  value = var.public-subnet.pub-subnet-1
}

output "ssh-command" {
  value = "ssh -i ${local_file.private-key.filename} ${local.user_name}@${aws_eip.EIP.public_ip}" 
}